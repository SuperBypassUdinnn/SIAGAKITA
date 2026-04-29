package user

import (
	"context"
	"errors"
	"fmt"

	"siagakita-backend/internal/config"
	"siagakita-backend/internal/domain/otp"
	"siagakita-backend/internal/utils"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Service contains the business logic for the user domain.
type Service struct {
	repo   *Repository
	cfg    *config.Config
	otpSvc otp.Service
}

// NewService creates a new user Service.
func NewService(repo *Repository, cfg *config.Config, otpSvc otp.Service) *Service {
	return &Service{repo: repo, cfg: cfg, otpSvc: otpSvc}
}

// ─── Register ─────────────────────────────────────────────────────────────────

// RegisterResult dikembalikan oleh Register — tidak mengandung JWT karena
// pengguna harus verifikasi email terlebih dahulu.
type RegisterResult struct {
	Message string `json:"message"`
	Email   string `json:"email"`
}

// Register membuat akun baru dan mengirimkan OTP ke email.
// JWT hanya diterbitkan setelah pengguna memverifikasi emailnya via VerifyRegisterOTP.
func (s *Service) Register(ctx context.Context, req *RegisterRequest) (*RegisterResult, error) {
	if req.FullName == "" || req.Email == "" || req.Password == "" {
		return nil, errors.New("full_name, email, dan password wajib diisi")
	}
	if len(req.Password) < 8 {
		return nil, errors.New("password minimal 8 karakter")
	}

	// Cek duplikasi email
	if _, err := s.repo.FindByEmail(req.Email); err == nil {
		return nil, errors.New("email sudah terdaftar")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		return nil, err
	}

	user := &User{
		FullName:        req.FullName,
		Email:           req.Email,
		PasswordHash:    string(hash),
		Role:            "civilian",
		IsEmailVerified: false,
		IsPhoneVerified: false,
	}
	if err := s.repo.CreateUser(user); err != nil {
		return nil, err
	}

	// Kirim OTP ke email untuk verifikasi
	if err := s.otpSvc.RequestEmailOTP(ctx, req.Email, "register"); err != nil {
		// Rollback: hapus user yang baru dibuat agar email bisa dipakai ulang
		_ = s.repo.DeleteUserByEmail(req.Email)
		return nil, fmt.Errorf("Gagal mengirim OTP ke email: %w", err)
	}

	return &RegisterResult{
		Message: "Akun berhasil dibuat. Masukkan kode OTP yang telah dikirimkan ke email Anda.",
		Email:   req.Email,
	}, nil
}

// ─── VerifyRegisterOTP ────────────────────────────────────────────────────────

// VerifyRegisterOTP memverifikasi OTP email saat pendaftaran dan menerbitkan JWT.
func (s *Service) VerifyRegisterOTP(ctx context.Context, email, code string) (*AuthResponse, error) {
	if err := s.otpSvc.VerifyEmailOTP(ctx, email, "register", code); err != nil {
		return nil, err
	}

	user, err := s.repo.FindByEmail(email)
	if err != nil {
		return nil, errors.New("akun tidak ditemukan")
	}

	// Tandai email terverifikasi
	if err := s.repo.SetEmailVerified(user.ID); err != nil {
		return nil, err
	}
	user.IsEmailVerified = true

	return s.buildAuthResponse(user)
}

// ─── Login (2FA — Email + Password → OTP ke email) ───────────────────────────

// LoginStep1Result dikembalikan dari Login — tidak mengandung JWT.
type LoginStep1Result struct {
	Message string `json:"message"`
	Email   string `json:"email"`
}

// Login memvalidasi email + password lalu langsung menerbitkan JWT.
// Tidak ada langkah OTP pada login — low-friction access.
func (s *Service) Login(ctx context.Context, req *LoginRequest) (*AuthResponse, error) {
	user, err := s.repo.FindByEmail(req.Email)
	if err != nil {
		return nil, errors.New("email atau password salah")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("email atau password salah")
	}
	return s.buildAuthResponse(user)
}

// ─── VerifyLoginOTP ───────────────────────────────────────────────────────────

// VerifyLoginOTP memverifikasi OTP email pada langkah login kedua dan menerbitkan JWT.
func (s *Service) VerifyLoginOTP(ctx context.Context, email, code string) (*AuthResponse, error) {
	if err := s.otpSvc.VerifyEmailOTP(ctx, email, "login", code); err != nil {
		return nil, err
	}

	user, err := s.repo.FindByEmail(email)
	if err != nil {
		return nil, errors.New("akun tidak ditemukan")
	}

	return s.buildAuthResponse(user)
}

// ─── Phone Verification (dalam Profile) ──────────────────────────────────────

// RequestPhoneVerification menyimpan nomor HP sementara dan mengirim OTP via WA.
func (s *Service) RequestPhoneVerification(ctx context.Context, userID, phone string) error {
	// Simpan nomor HP terlebih dahulu (is_phone_verified masih false)
	if err := s.repo.UpdatePhoneNumber(userID, phone); err != nil {
		return err
	}
	return s.otpSvc.RequestOTP(ctx, phone)
}

// ConfirmPhoneOTP memverifikasi OTP WA dan menandai nomor HP sebagai terverifikasi.
func (s *Service) ConfirmPhoneOTP(ctx context.Context, userID, phone, code string) error {
	if err := s.otpSvc.VerifyOTP(ctx, phone, code); err != nil {
		return err
	}
	return s.repo.SetPhoneVerified(userID)
}

// ─── Profile ──────────────────────────────────────────────────────────────────

// SaveBiodata delegates transactional biodata saving to the repository.
func (s *Service) SaveBiodata(userID string, req *BiodataRequest) error {
	return s.repo.SaveBiodata(userID, req)
}

// GetProfile returns the combined profile for the given userID.
func (s *Service) GetProfile(userID string) (*ProfileResponse, error) {
	return s.repo.GetProfile(userID)
}

// ─── Token builder ────────────────────────────────────────────────────────────

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
			IsEmailVerified:     user.IsEmailVerified,
			IsPhoneVerified:     user.IsPhoneVerified,
		},
	}, nil
}
