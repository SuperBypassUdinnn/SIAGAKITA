package incident

import "time"

// ─── DB Models ────────────────────────────────────────────────────────────────

type Incident struct {
	ID            uint       `gorm:"primaryKey;autoIncrement" json:"id"`
	ReporterID    string     `gorm:"type:uuid;not null" json:"reporter_id"`
	IncidentType  *string    `json:"incident_type,omitempty"`
	Latitude      float64    `gorm:"not null" json:"latitude"`
	Longitude     float64    `gorm:"not null" json:"longitude"`
	Status        string     `gorm:"default:'grace_period'" json:"status"`
	TriggerMethod string     `gorm:"default:'timeout'" json:"trigger_method"`
	AddressDetail *string    `json:"address_detail,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
	ResolvedAt    *time.Time `json:"resolved_at,omitempty"`
}

type IncidentResponse struct {
	ID          uint       `gorm:"primaryKey;autoIncrement" json:"id"`
	IncidentID  uint       `gorm:"not null" json:"incident_id"`
	ResponderID string     `gorm:"type:uuid;not null" json:"responder_id"`
	Status      string     `gorm:"default:'en_route'" json:"status"`
	AcceptedAt  *time.Time `json:"accepted_at,omitempty"`
	ArrivedAt   *time.Time `json:"arrived_at,omitempty"`
}

type VolunteerReputation struct {
	UserID       string    `gorm:"type:uuid;primaryKey" json:"user_id"`
	ExpPoints    int       `gorm:"default:0" json:"exp_points"`
	RankID       *uint     `json:"rank_id,omitempty"`
	TotalRescues int       `gorm:"default:0" json:"total_rescues"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type MRank struct {
	ID       uint   `gorm:"primaryKey" json:"id"`
	RankName string `json:"rank_name"`
	MinExp   int    `json:"min_exp"`
	IconURL  string `json:"icon_url"`
}

// ─── Request DTOs ─────────────────────────────────────────────────────────────

type TriggerSOSRequest struct {
	Latitude      float64 `json:"latitude"`
	Longitude     float64 `json:"longitude"`
	IncidentType  *string `json:"incident_type"`
	AddressDetail *string `json:"address_detail"`
	TriggerMethod string  `json:"trigger_method"` // 'user' | 'timeout'
}

type UpdateLocationRequest struct {
	IncidentID uint    `json:"incident_id"`
	Latitude   float64 `json:"latitude"`
	Longitude  float64 `json:"longitude"`
}

// ─── Response DTOs ─────────────────────────────────────────────────────────────

type TriggerSOSResponse struct {
	IncidentID uint   `json:"incident_id"`
	Status     string `json:"status"`
	Message    string `json:"message"`
}

type ResolveResponse struct {
	Resolved     bool   `json:"resolved"`
	XPEarned     int    `json:"xp_earned"`
	NewTotalXP   int    `json:"new_total_xp"`
	TotalRescues int    `json:"total_rescues"`
	RankUp       bool   `json:"rank_up"`
	NewRank      string `json:"new_rank,omitempty"`
}

type ActiveIncidentResponse struct {
	IncidentID uint    `json:"incident_id"`
	Status     string  `json:"status"`
	Latitude   float64 `json:"latitude"`
	Longitude  float64 `json:"longitude"`
	CreatedAt  string  `json:"created_at"`
}
