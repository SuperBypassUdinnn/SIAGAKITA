package user

import (
	"errors"

	"siagakita-backend/internal/config"
	"siagakita-backend/internal/utils"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Service contains the business logic for the user domain.
type Service struct {
	repo *Repository
	cfg  *config.Config
}

// NewService creates a new user Service.
func NewService(repo *Repository, cfg *config.Config) *Service {
	return &Service{repo: repo, cfg: cfg}
}

// Register hashes the password, creates the user, and returns JWT tokens.
func (s *Service) Register(req *RegisterRequest) (*AuthResponse, error) {
	if req.FullName == "" || req.Email == "" || req.Password == "" {
		return nil, errors.New("full_name, email, dan password wajib diisi")
	}
	if len(req.Password) < 8 {
		return nil, errors.New("password minimal 8 karakter")
	}

	_, err := s.repo.FindByEmail(req.Email)
	if err == nil {
		return nil, errors.New("email sudah terdaftar")
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		return nil, err
	}

	user := &User{
		FullName:     req.FullName,
		Email:        req.Email,
		PasswordHash: string(hash),
		Role:         "masyarakat",
	}
	if err := s.repo.CreateUser(user); err != nil {
		return nil, err
	}

	return s.buildAuthResponse(user)
}

// Login verifies credentials and returns JWT tokens.
func (s *Service) Login(req *LoginRequest) (*AuthResponse, error) {
	user, err := s.repo.FindByEmail(req.Email)
	if err != nil {
		return nil, errors.New("email atau password salah")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("email atau password salah")
	}

	return s.buildAuthResponse(user)
}

// SaveBiodata delegates transactional biodata saving to the repository.
func (s *Service) SaveBiodata(userID string, req *BiodataRequest) error {
	return s.repo.SaveBiodata(userID, req)
}

// GetProfile returns the combined profile for the given userID.
func (s *Service) GetProfile(userID string) (*ProfileResponse, error) {
	return s.repo.GetProfile(userID)
}

// buildAuthResponse generates both tokens and returns the auth response DTO.
func (s *Service) buildAuthResponse(user *User) (*AuthResponse, error) {
	accessToken, err := utils.GenerateAccessToken(user.ID, user.Role, s.cfg.JWTSecret, s.cfg.JWTAccessTTL)
	if err != nil {
		return nil, err
	}

	refreshToken, err := utils.GenerateRefreshToken(user.ID, user.Role, s.cfg.JWTSecret, s.cfg.JWTRefreshTTL)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: UserInfo{
			ID:                  user.ID,
			FullName:            user.FullName,
			Email:               user.Email,
			Role:                user.Role,
			IsVerifiedVolunteer: user.IsVerifiedVolunteer,
		},
	}, nil
}
