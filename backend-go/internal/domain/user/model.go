package user

import "time"

// ─── DB Models ────────────────────────────────────────────────────────────────

type User struct {
	ID                  string     `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	FullName            string     `gorm:"not null" json:"full_name"`
	NIK                 *string    `json:"nik,omitempty"`
	DateOfBirth         *time.Time `json:"date_of_birth,omitempty"`
	PhoneNumber         *string    `json:"phone_number,omitempty"`
	Email               string     `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash        string     `gorm:"not null" json:"-"`
	Role                string     `gorm:"default:'masyarakat'" json:"role"`
	IsVerifiedVolunteer bool       `gorm:"default:false" json:"is_verified_volunteer"`
	CreatedAt           time.Time  `json:"created_at"`
	UpdatedAt           time.Time  `json:"updated_at"`
	DeletedAt           *time.Time `gorm:"index" json:"-"`
}

type UserMedicalProfile struct {
	UserID            string    `gorm:"type:uuid;primaryKey" json:"user_id"`
	BloodType         *string   `json:"blood_type,omitempty"`
	Allergies         *string   `json:"allergies,omitempty"`
	MedicalConditions *string   `json:"medical_conditions,omitempty"`
	HeightCm          *int      `json:"height_cm,omitempty"`
	WeightKg          *int      `json:"weight_kg,omitempty"`
	Alamat            *string   `json:"alamat,omitempty"`
	UpdatedAt         time.Time `json:"updated_at"`
}

type EmergencyContact struct {
	ID           string     `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID       string     `gorm:"type:uuid;not null;index" json:"user_id"`
	ContactName  string     `json:"contact_name"`
	ContactPhone string     `json:"contact_phone"`
	Relation     *string    `json:"relation,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	DeletedAt    *time.Time `gorm:"index" json:"-"`
}

type VolunteerReputation struct {
	UserID       string    `gorm:"type:uuid;primaryKey" json:"user_id"`
	ExpPoints    int       `gorm:"default:0" json:"exp_points"`
	RankID       *int      `json:"rank_id,omitempty"`
	TotalRescues int       `gorm:"default:0" json:"total_rescues"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// ─── Request DTOs ──────────────────────────────────────────────────────────────

type RegisterRequest struct {
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type BiodataRequest struct {
	NIK                   *string `json:"nik"`
	DateOfBirth           *string `json:"date_of_birth"` // Format: DD-MM-YYYY
	BloodType             *string `json:"blood_type"`
	Allergies             *string `json:"allergies"`
	MedicalConditions     *string `json:"medical_conditions"`
	HeightCm              *int    `json:"height_cm"`
	WeightKg              *int    `json:"weight_kg"`
	Alamat                *string `json:"alamat"`
	EmergencyContactName  *string `json:"emergency_contact_name"`
	EmergencyContactPhone *string `json:"emergency_contact_phone"`
	EmergencyRelation     *string `json:"emergency_relation"`
}

// ─── Response DTOs ─────────────────────────────────────────────────────────────

type AuthResponse struct {
	AccessToken  string   `json:"access_token"`
	RefreshToken string   `json:"refresh_token"`
	User         UserInfo `json:"user"`
}

type UserInfo struct {
	ID                  string `json:"id"`
	FullName            string `json:"full_name"`
	Email               string `json:"email"`
	Role                string `json:"role"`
	IsVerifiedVolunteer bool   `json:"is_verified_volunteer"`
}

type ProfileResponse struct {
	ID                  string               `json:"id"`
	FullName            string               `json:"full_name"`
	NIK                 *string              `json:"nik,omitempty"`
	Email               string               `json:"email"`
	PhoneNumber         *string              `json:"phone_number,omitempty"`
	DateOfBirth         *string              `json:"date_of_birth,omitempty"`
	Role                string               `json:"role"`
	IsVerifiedVolunteer bool                 `json:"is_verified_volunteer"`
	MedicalData         *UserMedicalProfile  `json:"medical_data,omitempty"`
	EmergencyContacts   []EmergencyContact   `json:"emergency_contacts"`
	VolunteerReputation *VolunteerReputation `json:"volunteer_reputation,omitempty"`
}
