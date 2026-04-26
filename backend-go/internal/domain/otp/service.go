package otp

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"github.com/redis/go-redis/v9"
)

const (
	otpTTL      = 3 * time.Minute  // OTP kedaluwarsa dalam 3 menit
	cooldownTTL = 1 * time.Minute  // Cooldown 1 menit antar request
)

// Service mendefinisikan kontrak logika bisnis OTP.
type Service interface {
	// RequestOTP membuat kode OTP, menyimpan ke Redis, dan mengirim via WA.
	// Mengembalikan error jika masih dalam cooldown atau pengiriman gagal.
	RequestOTP(ctx context.Context, phone string) error

	// VerifyOTP memverifikasi kode OTP untuk nomor HP tertentu.
	// Jika cocok, kode dihapus dari Redis (anti-replay).
	// Mengembalikan error jika kode salah atau kedaluwarsa.
	VerifyOTP(ctx context.Context, phone, code string) error
}

type service struct {
	rdb     *redis.Client
	gateway Gateway
}

// NewService membuat instance OTP service.
func NewService(rdb *redis.Client, gateway Gateway) Service {
	return &service{rdb: rdb, gateway: gateway}
}

// ─── Key Helpers ─────────────────────────────────────────────────────────────

func otpKey(phone string) string {
	return fmt.Sprintf("otp:register:%s", phone)
}

func cooldownKey(phone string) string {
	return fmt.Sprintf("otp_cooldown:%s", phone)
}

// ─── RequestOTP ──────────────────────────────────────────────────────────────

func (s *service) RequestOTP(ctx context.Context, phone string) error {
	// 1. Cek rate limit — tolak jika cooldown masih aktif
	exists, err := s.rdb.Exists(ctx, cooldownKey(phone)).Result()
	if err != nil {
		return fmt.Errorf("otp/service: cek cooldown gagal: %w", err)
	}
	if exists > 0 {
		return errors.New("Tunggu 1 menit sebelum meminta kode baru")
	}

	// 2. Generate kode 6 digit acak (100000–999999)
	//nolint:gosec // OTP tidak butuh CSPRNG, cukup random biasa
	code := fmt.Sprintf("%06d", rand.Intn(900000)+100000)

	// 3. Simpan OTP ke Redis dengan TTL 3 menit
	if err := s.rdb.SetEx(ctx, otpKey(phone), code, otpTTL).Err(); err != nil {
		return fmt.Errorf("otp/service: simpan OTP gagal: %w", err)
	}

	// 4. Simpan cooldown key — mencegah spam request
	if err := s.rdb.SetEx(ctx, cooldownKey(phone), "1", cooldownTTL).Err(); err != nil {
		return fmt.Errorf("otp/service: simpan cooldown gagal: %w", err)
	}

	// 5. Kirim pesan WhatsApp via gateway
	message := fmt.Sprintf(
		"%s adalah kode OTP SiagaKita Anda. Berlaku 3 menit. JANGAN BERIKAN KODE INI KE SIAPAPUN.",
		code,
	)
	if err := s.gateway.Send(phone, message); err != nil {
		// Rollback OTP & cooldown jika pengiriman gagal
		_ = s.rdb.Del(ctx, otpKey(phone), cooldownKey(phone))
		return fmt.Errorf("otp/service: kirim WA gagal: %w", err)
	}

	return nil
}

// ─── VerifyOTP ───────────────────────────────────────────────────────────────

func (s *service) VerifyOTP(ctx context.Context, phone, code string) error {
	// 1. Ambil kode dari Redis
	stored, err := s.rdb.Get(ctx, otpKey(phone)).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return errors.New("OTP kedaluwarsa atau nomor tidak ditemukan")
		}
		return fmt.Errorf("otp/service: ambil OTP gagal: %w", err)
	}

	// 2. Bandingkan kode
	if stored != code {
		return errors.New("Kode OTP salah")
	}

	// 3. Hapus OTP — mencegah penggunaan ulang (anti-replay)
	_ = s.rdb.Del(ctx, otpKey(phone))

	return nil
}
