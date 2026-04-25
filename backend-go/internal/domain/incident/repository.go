package incident

import (
	"errors"
	"time"

	"gorm.io/gorm"
)

// Repository handles all DB operations for the incident domain.
type Repository struct {
	db *gorm.DB
}

// NewRepository creates a new incident Repository.
func NewRepository(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// CreateIncident inserts a new incident row and returns its ID.
func (r *Repository) CreateIncident(inc *Incident) error {
	return r.db.Create(inc).Error
}

// FindByID fetches an incident by primary key.
func (r *Repository) FindByID(id uint) (*Incident, error) {
	var inc Incident
	if err := r.db.First(&inc, id).Error; err != nil {
		return nil, err
	}
	return &inc, nil
}

// UpdateStatus changes an incident's status field.
func (r *Repository) UpdateStatus(id uint, status string) error {
	return r.db.Model(&Incident{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":     status,
			"updated_at": time.Now(),
		}).Error
}

// MarkResolved sets status=resolved and resolved_at=now for an incident.
func (r *Repository) MarkResolved(id uint) (*Incident, error) {
	now := time.Now()
	if err := r.db.Model(&Incident{}).Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":      "resolved",
			"resolved_at": now,
			"updated_at":  now,
		}).Error; err != nil {
		return nil, err
	}
	return r.FindByID(id)
}

// CreateResponse inserts an incident_responses record.
func (r *Repository) CreateResponse(resp *IncidentResponse) error {
	now := time.Now()
	resp.AcceptedAt = &now
	return r.db.Create(resp).Error
}

// GetReputation fetches a volunteer's reputation row (or nil if not found).
func (r *Repository) GetReputation(userID string) (*VolunteerReputation, error) {
	var rep VolunteerReputation
	err := r.db.Where("user_id = ?", userID).First(&rep).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &rep, err
}

// UpsertReputation inserts or updates a volunteer's reputation row.
func (r *Repository) UpsertReputation(userID string, addXP, addRescues int) (*VolunteerReputation, error) {
	var rep VolunteerReputation
	err := r.db.Where("user_id = ?", userID).First(&rep).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		// Create new reputation row
		rep = VolunteerReputation{
			UserID:       userID,
			ExpPoints:    addXP,
			TotalRescues: addRescues,
			UpdatedAt:    time.Now(),
		}
		return &rep, r.db.Create(&rep).Error
	}
	if err != nil {
		return nil, err
	}

	// Update existing row
	rep.ExpPoints += addXP
	rep.TotalRescues += addRescues
	rep.UpdatedAt = time.Now()
	return &rep, r.db.Save(&rep).Error
}

// GetRankForXP returns the highest rank whose min_exp does not exceed totalXP.
func (r *Repository) GetRankForXP(totalXP int) (*MRank, error) {
	var rank MRank
	err := r.db.Where("min_exp <= ?", totalXP).Order("min_exp DESC").First(&rank).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &rank, err
}

// UpdateRank sets the rank_id on a volunteer_reputation row.
func (r *Repository) UpdateRank(userID string, rankID uint) error {
	return r.db.Model(&VolunteerReputation{}).Where("user_id = ?", userID).
		Updates(map[string]interface{}{
			"rank_id":    rankID,
			"updated_at": time.Now(),
		}).Error
}
