package incident

import (
	"errors"
	"math"
	"time"
)

// incidentTypeMultiplier maps incident_type strings to XP multipliers.
var incidentTypeMultiplier = map[string]float64{
	"Medis":        1.5,
	"Kebakaran":    1.3,
	"Bencana Alam": 1.4,
	"Kecelakaan":   1.2,
	"Kriminalitas": 1.0,
}

// Service contains the business logic for the incident domain.
type Service struct {
	repo *Repository
}

// NewService creates a new incident Service.
func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

// ─── TriggerSOS ───────────────────────────────────────────────────────────────

func (s *Service) TriggerSOS(reporterID string, req *TriggerSOSRequest) (*TriggerSOSResponse, error) {
	inc := &Incident{
		ReporterID:    reporterID,
		Latitude:      req.Latitude,
		Longitude:     req.Longitude,
		IncidentType:  req.IncidentType,
		AddressDetail: req.AddressDetail,
		TriggerMethod: req.TriggerMethod,
		Status:        "broadcasting",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
	if err := s.repo.CreateIncident(inc); err != nil {
		return nil, err
	}
	return &TriggerSOSResponse{
		IncidentID: inc.ID,
		Status:     inc.Status,
		Message:    "SOS berhasil dikirim. Tim sedang dihubungi.",
	}, nil
}

// ─── CancelSOS ────────────────────────────────────────────────────────────────

func (s *Service) CancelSOS(id uint, reporterID string) error {
	inc, err := s.repo.FindByID(id)
	if err != nil {
		return err
	}
	if inc.ReporterID != reporterID {
		return errors.New("unauthorized")
	}
	return s.repo.MarkCancelled(id)
}

// ─── UpdateLocation ───────────────────────────────────────────────────────────

func (s *Service) UpdateLocation(id uint, lat, lng float64) error {
	return s.repo.UpdateLocation(id, lat, lng)
}

// ─── GetActive ────────────────────────────────────────────────────────────────

func (s *Service) GetActive(reporterID string) (*ActiveIncidentResponse, error) {
	inc, err := s.repo.FindActiveByReporter(reporterID)
	if err != nil {
		return nil, err
	}
	if inc == nil {
		return nil, nil
	}
	return &ActiveIncidentResponse{
		IncidentID: inc.ID,
		Status:     inc.Status,
		Latitude:   inc.Latitude,
		Longitude:  inc.Longitude,
		CreatedAt:  inc.CreatedAt.Format(time.RFC3339),
	}, nil
}

// Resolve marks an incident as resolved, calculates XP, awards it to the
// responder, and handles rank promotion if the XP threshold is crossed.
func (s *Service) Resolve(incidentID uint, responderID string) (*ResolveResponse, error) {
	// 1. Mark incident resolved and capture timestamps
	inc, err := s.repo.MarkResolved(incidentID)
	if err != nil {
		return nil, err
	}

	// 2. Calculate response duration in minutes
	durationMinutes := inc.ResolvedAt.Sub(inc.CreatedAt).Minutes()

	// 3. Calculate XP
	baseXP := 100
	speedBonus := math.Max(0, 50-durationMinutes) // faster = more bonus
	multiplier := 1.0
	if inc.IncidentType != nil {
		if m, ok := incidentTypeMultiplier[*inc.IncidentType]; ok {
			multiplier = m
		}
	}
	totalXP := int((float64(baseXP) + speedBonus) * multiplier)

	// 4. Upsert volunteer_reputation
	rep, err := s.repo.UpsertReputation(responderID, totalXP, 1)
	if err != nil {
		return nil, err
	}

	// 5. Check for rank promotion
	rankUp := false
	newRankName := ""

	newRank, err := s.repo.GetRankForXP(rep.ExpPoints)
	if err != nil {
		return nil, err
	}
	if newRank != nil {
		oldRankID := uint(0)
		if rep.RankID != nil {
			oldRankID = *rep.RankID
		}
		if newRank.ID != oldRankID {
			rankUp = true
			newRankName = newRank.RankName
			_ = s.repo.UpdateRank(responderID, newRank.ID)
		}
	}

	return &ResolveResponse{
		Resolved:     true,
		XPEarned:     totalXP,
		NewTotalXP:   rep.ExpPoints,
		TotalRescues: rep.TotalRescues,
		RankUp:       rankUp,
		NewRank:      newRankName,
	}, nil
}
