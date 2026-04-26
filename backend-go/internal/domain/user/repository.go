package user

import (
	"fmt"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// Repository handles all database operations for the user domain.
type Repository struct {
	db *gorm.DB
}

// NewRepository creates a new user Repository.
func NewRepository(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// CreateUser inserts a new user record.
func (r *Repository) CreateUser(user *User) error {
	return r.db.Create(user).Error
}

// FindByEmail retrieves a non-deleted user by email.
func (r *Repository) FindByEmail(email string) (*User, error) {
	var user User
	err := r.db.Where("email = ? AND deleted_at IS NULL", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByID retrieves a non-deleted user by primary key.
func (r *Repository) FindByID(id string) (*User, error) {
	var user User
	err := r.db.Where("id = ? AND deleted_at IS NULL", id).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// SaveBiodata runs a DB transaction that updates three tables atomically:
// users, user_medical_profiles, and emergency_contacts.
func (r *Repository) SaveBiodata(userID string, req *BiodataRequest) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// 1. Update users table
		userUpdates := map[string]interface{}{
			"updated_at": time.Now(),
		}
		if req.NIK != nil {
			userUpdates["nik"] = *req.NIK
		}
		if req.DateOfBirth != nil {
			parsed, err := time.Parse("02-01-2006", *req.DateOfBirth)
			if err != nil {
				return fmt.Errorf("format date_of_birth tidak valid, gunakan DD-MM-YYYY: %w", err)
			}
			userUpdates["date_of_birth"] = parsed
		}
		if err := tx.Model(&User{}).Where("id = ?", userID).Updates(userUpdates).Error; err != nil {
			return err
		}

		// 2. Upsert user_medical_profiles
		medical := UserMedicalProfile{
			UserID:            userID,
			BloodType:         req.BloodType,
			Allergies:         req.Allergies,
			MedicalConditions: req.MedicalConditions,
			HeightCm:          req.HeightCm,
			WeightKg:          req.WeightKg,
			Alamat:            req.Alamat,
			UpdatedAt:         time.Now(),
		}
		if err := tx.Clauses(clause.OnConflict{
			Columns: []clause.Column{{Name: "user_id"}},
			DoUpdates: clause.AssignmentColumns([]string{
				"blood_type", "allergies", "medical_conditions",
				"height_cm", "weight_kg", "alamat", "updated_at",
			}),
		}).Create(&medical).Error; err != nil {
			return err
		}

		// 3. Insert emergency contact (if provided)
		if req.EmergencyContactName != nil && req.EmergencyContactPhone != nil {
			contact := EmergencyContact{
				UserID:       userID,
				ContactName:  *req.EmergencyContactName,
				ContactPhone: *req.EmergencyContactPhone,
				Relation:     req.EmergencyRelation,
			}
			if err := tx.Create(&contact).Error; err != nil {
				return err
			}
		}

		return nil
	})
}

// GetProfile fetches the combined profile with LEFT JOINs across four tables.
func (r *Repository) GetProfile(userID string) (*ProfileResponse, error) {
	user, err := r.FindByID(userID)
	if err != nil {
		return nil, err
	}

	var medical UserMedicalProfile
	r.db.Where("user_id = ?", userID).First(&medical)

	var contacts []EmergencyContact
	r.db.Where("user_id = ? AND deleted_at IS NULL", userID).Find(&contacts)

	var reputation VolunteerReputation
	r.db.Where("user_id = ?", userID).First(&reputation)

	resp := &ProfileResponse{
		ID:                  user.ID,
		FullName:            user.FullName,
		NIK:                 user.NIK,
		Email:               user.Email,
		PhoneNumber:         user.PhoneNumber,
		Role:                user.Role,
		IsVerifiedVolunteer: user.IsVerifiedVolunteer,
		EmergencyContacts:   contacts,
	}

	if user.DateOfBirth != nil {
		dob := user.DateOfBirth.Format("02-01-2006")
		resp.DateOfBirth = &dob
	}
	if medical.UserID != "" {
		resp.MedicalData = &medical
	}
	if reputation.UserID != "" {
		resp.VolunteerReputation = &reputation
	}

	return resp, nil
}
