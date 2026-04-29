package otp

import (
	"fmt"
	"net/smtp"
	"strings"
)

// EmailGateway mengirim kode OTP via SMTP email.
type EmailGateway interface {
	SendEmail(toEmail, subject, body string) error
}

// smtpEmailGateway implementasi SMTP untuk kirim email.
type smtpEmailGateway struct {
	host     string
	port     string
	username string
	password string
	from     string
}

// NewSMTPEmailGateway membuat instance SMTP email gateway.
func NewSMTPEmailGateway(host, port, username, password, from string) EmailGateway {
	return &smtpEmailGateway{
		host:     host,
		port:     port,
		username: username,
		password: password,
		from:     from,
	}
}

// SendEmail mengirim email via SMTP.
func (g *smtpEmailGateway) SendEmail(toEmail, subject, body string) error {
	auth := smtp.PlainAuth("", g.username, g.password, g.host)

	headers := strings.Join([]string{
		fmt.Sprintf("From: SiagaKita <%s>", g.from),
		fmt.Sprintf("To: %s", toEmail),
		fmt.Sprintf("Subject: %s", subject),
		"MIME-Version: 1.0",
		"Content-Type: text/plain; charset=UTF-8",
	}, "\r\n")

	message := fmt.Sprintf("%s\r\n\r\n%s", headers, body)

	addr := fmt.Sprintf("%s:%s", g.host, g.port)
	if err := smtp.SendMail(addr, auth, g.from, []string{toEmail}, []byte(message)); err != nil {
		return fmt.Errorf("otp/email: kirim email gagal: %w", err)
	}

	return nil
}
