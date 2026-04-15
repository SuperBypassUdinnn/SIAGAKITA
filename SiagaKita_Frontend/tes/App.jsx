import React, { useState, useEffect, useRef } from "react";
import {
  AlertCircle,
  Map as MapIcon,
  MessageSquare,
  User,
  ShieldCheck,
  Activity,
  Download,
  Send,
  Phone,
  FileText,
  BookOpen,
  WifiOff,
  Fingerprint,
  Clock,
  MapPin,
  Sun,
  Moon,
  Mail,
  Heart,
  PhoneCall,
  Search,
  ChevronDown,
  Users,
} from "lucide-react";

const App = () => {
  const [activeTab, setActiveTab] = useState("home");
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [sosProgress, setSosProgress] = useState(0);
  const [isHolding, setIsHolding] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [expandedGuide, setExpandedGuide] = useState(null);
  const [showSOSAlert, setShowSOSAlert] = useState(false); // State baru untuk popup
  const timerRef = useRef(null);

  // Palet warna: Menggunakan Biru Deep Royal agar terlihat jelas birunya (bukan hitam)
  const colors = {
    primary: "#ff7418", // Oranye Utama
    primaryLight: "#ffa265",
    primaryDark: "#cb5100",
    accent: "#18a3ff",
    bg: isDarkMode ? "#0d1b3e" : "#f1f5f9", // Deep Royal Navy
    card: isDarkMode ? "#162a5a" : "#ffffff", // Cobalt Blue
    text: isDarkMode ? "#ffffff" : "#1e293b",
    textMuted: isDarkMode ? "#9ca3af" : "#64748b",
    border: isDarkMode ? "rgba(56, 189, 248, 0.2)" : "rgba(0,0,0,0.05)",
  };

  // Logika SOS Tahan 5 Detik
  const startHolding = () => {
    setIsHolding(true);
    let start = 0;
    timerRef.current = setInterval(() => {
      start += 2;
      setSosProgress(start);
      if (start >= 100) {
        clearInterval(timerRef.current);
        triggerSOS();
      }
    }, 100);
  };

  const stopHolding = () => {
    setIsHolding(false);
    clearInterval(timerRef.current);
    setSosProgress(0);
  };

  const triggerSOS = () => {
    // Ubah state, bukan memanipulasi DOM secara langsung
    setShowSOSAlert(true);
    setTimeout(() => setShowSOSAlert(false), 3000);

    setSosProgress(0);
    setIsHolding(false);
  };

  const emergencyGuides = [
    {
      id: 1,
      title: "Pendarahan Hebat",
      type: "Medis",
      steps: [
        "Tekan luka kuat-kuat dengan kain bersih.",
        "Tinggikan posisi luka di atas jantung jika memungkinkan.",
        "Jangan lepas kain pertama jika darah tembus, tumpuk dengan kain baru.",
        "Segera cari bantuan darurat.",
      ],
    },
    {
      id: 2,
      title: "Luka Bakar",
      type: "Medis",
      steps: [
        "Aliri area luka dengan air mengalir (bukan es) selama 15-20 menit.",
        "Lepaskan pakaian atau perhiasan di sekitar luka sebelum membengkak.",
        "Tutup luka secara longgar dengan plastik wrap atau kain bersih.",
        "Jangan pernah memecahkan lepuhan.",
      ],
    },
    {
      id: 3,
      title: "Tersedak (Dewasa)",
      type: "Medis",
      steps: [
        "Berdirilah di belakang korban dan peluk pinggangnya.",
        "Kepalkan satu tangan sedikit di atas pusarnya.",
        "Genggam kepalan dengan tangan satunya, lalu hentakkan ke atas dan ke dalam (Heimlich Maneuver).",
        "Ulangi sampai benda asing keluar.",
      ],
    },
    {
      id: 4,
      title: "Gempa Bumi",
      type: "Bencana",
      steps: [
        "Lakukan Drop, Cover, Hold On (Merunduk, Berlindung di bawah meja yang kuat, Berpegangan).",
        "Jauhi jendela, kaca, dan perabotan yang bisa jatuh.",
        "Jika di luar, cari area terbuka jauh dari bangunan, pohon, dan tiang listrik.",
        "Jangan gunakan lift saat evakuasi.",
      ],
    },
    {
      id: 5,
      title: "Henti Jantung (CPR/RJP)",
      type: "Medis",
      steps: [
        "Pastikan lingkungan aman dan hubungi bantuan darurat.",
        "Cek respon dan napas korban.",
        "Letakkan pangkal telapak tangan di tengah dada korban.",
        "Tekan dada kuat dan cepat (100-120 kali per menit) dengan kedalaman 5 cm.",
        "Lakukan terus sampai bantuan datang atau korban menunjukkan respon.",
      ],
    },
  ];

  const filteredGuides = emergencyGuides.filter(
    (g) =>
      g.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      g.type.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  const renderContent = () => {
    switch (activeTab) {
      case "home":
        return (
          <div
            className="flex flex-col items-center justify-between h-full py-8 px-6 overflow-y-auto"
            style={{ color: colors.text }}
          >
            <div className="w-full flex justify-between items-center">
              <div className="w-10"></div>
              <div className="text-center">
                <h1
                  className="text-2xl font-bold tracking-tight"
                  style={{ color: colors.primary }}
                >
                  SiagaKita
                </h1>
                <p className="text-sm opacity-60">
                  Tekan dan tahan untuk bantuan
                </p>
              </div>
              <button
                onClick={() => setIsDarkMode(!isDarkMode)}
                className="p-2 rounded-xl transition-colors shadow-sm"
                style={{ backgroundColor: colors.card }}
              >
                {isDarkMode ? (
                  <Sun size={20} className="text-yellow-400" />
                ) : (
                  <Moon size={20} className="text-blue-600" />
                )}
              </button>
            </div>

            <div className="relative flex items-center justify-center py-12">
              {isHolding && (
                <div
                  className="absolute w-64 h-64 rounded-full animate-ping opacity-25"
                  style={{ backgroundColor: colors.primary }}
                ></div>
              )}

              <button
                onMouseDown={startHolding}
                onMouseUp={stopHolding}
                onTouchStart={startHolding}
                onTouchEnd={stopHolding}
                className="relative w-56 h-56 rounded-full flex flex-col items-center justify-center shadow-2xl transition-transform active:scale-95 z-10"
                style={{
                  background: `radial-gradient(circle, ${colors.primary} 0%, ${colors.primaryDark} 100%)`,
                  border: `8px solid ${
                    isHolding
                      ? colors.primaryLight
                      : isDarkMode
                        ? "#ffffff20"
                        : "#00000010"
                  }`,
                }}
              >
                <AlertCircle size={80} color="white" />
                <span className="text-4xl font-black text-white mt-2">SOS</span>
                <span className="text-xs text-white opacity-80 mt-1 uppercase font-bold tracking-widest text-center px-4">
                  Tahan 5 Detik
                </span>

                {isHolding && (
                  <svg
                    viewBox="0 0 224 224"
                    className="absolute -top-2 -left-2 w-[224px] h-[224px] -rotate-90 pointer-events-none"
                  >
                    <circle
                      cx="112"
                      cy="112"
                      r="108"
                      stroke="white"
                      strokeWidth="8"
                      fill="transparent"
                      strokeDasharray="678"
                      strokeDashoffset={678 - (678 * sosProgress) / 100}
                      className="transition-all duration-100 ease-linear"
                    />
                  </svg>
                )}
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 w-full">
              <button
                className="flex flex-col p-4 rounded-3xl items-center text-center justify-center space-y-2 transition-all shadow-sm active:scale-95"
                style={{ backgroundColor: colors.card }}
              >
                <div
                  className="p-3 rounded-2xl"
                  style={{ backgroundColor: `${colors.accent}15` }}
                >
                  <FileText color={colors.accent} size={28} />
                </div>
                <span className="font-bold text-sm">Laporkan</span>
                <span className="text-[10px] opacity-60 leading-tight">
                  Kirim bukti & titik lokasi
                </span>
              </button>

              <button
                className="flex flex-col p-4 rounded-3xl items-center text-center justify-center space-y-2 transition-all shadow-sm active:scale-95"
                style={{ backgroundColor: colors.card }}
              >
                <div
                  className="p-3 rounded-2xl"
                  style={{ backgroundColor: `${colors.primary}15` }}
                >
                  <BookOpen color={colors.primary} size={28} />
                </div>
                <span className="font-bold text-sm">Edukasi</span>
                <span className="text-[10px] opacity-60 leading-tight">
                  Panduan penyelamatan
                </span>
              </button>
            </div>
          </div>
        );

      case "guide":
        return (
          <div
            className="flex flex-col h-full"
            style={{ backgroundColor: colors.bg, color: colors.text }}
          >
            <div
              className="p-6 border-b flex flex-col space-y-4"
              style={{ borderColor: colors.border }}
            >
              <div className="flex items-center space-x-4">
                <div
                  className="p-3 rounded-2xl"
                  style={{ backgroundColor: `${colors.primary}15` }}
                >
                  <BookOpen color={colors.primary} />
                </div>
                <div>
                  <h2 className="font-bold text-lg text-primary">
                    Panduan Darurat
                  </h2>
                  <p className="text-xs text-green-500 font-medium flex items-center gap-1">
                    <ShieldCheck size={12} /> Database Lokal Aktif
                    (Offline/Online)
                  </p>
                </div>
              </div>
              <div className="relative">
                <Search
                  className="absolute left-3 top-2.5 opacity-50"
                  size={18}
                />
                <input
                  type="text"
                  placeholder="Cari tindakan (mis: Luka Bakar)..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full border-none rounded-xl py-2 pl-10 pr-4 focus:ring-2 focus:ring-orange-500 text-sm shadow-inner"
                  style={{ backgroundColor: colors.card, color: colors.text }}
                />
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-3">
              {filteredGuides.length > 0 ? (
                filteredGuides.map((guide) => (
                  <div
                    key={guide.id}
                    className="rounded-2xl border overflow-hidden transition-all shadow-sm"
                    style={{
                      borderColor: colors.border,
                      backgroundColor: colors.card,
                    }}
                  >
                    <button
                      onClick={() =>
                        setExpandedGuide(
                          expandedGuide === guide.id ? null : guide.id,
                        )
                      }
                      className="w-full p-4 flex items-center justify-between text-left"
                    >
                      <div>
                        <h3 className="font-bold text-sm">{guide.title}</h3>
                        <span className="text-[10px] opacity-60 uppercase tracking-wider font-bold">
                          {guide.type}
                        </span>
                      </div>
                      <ChevronDown
                        size={18}
                        className={`transition-transform duration-300 ${
                          expandedGuide === guide.id
                            ? "rotate-180 text-orange-500"
                            : "opacity-50"
                        }`}
                      />
                    </button>

                    {expandedGuide === guide.id && (
                      <div className="px-4 pb-4 pt-0">
                        <div
                          className="h-px w-full mb-3 opacity-10"
                          style={{ backgroundColor: colors.text }}
                        ></div>
                        <ol className="space-y-2 list-decimal list-inside text-xs opacity-90 leading-relaxed">
                          {guide.steps.map((step, idx) => (
                            <li key={idx} className="pl-1 text-justify">
                              <span className="ml-1">{step}</span>
                            </li>
                          ))}
                        </ol>
                      </div>
                    )}
                  </div>
                ))
              ) : (
                <div className="text-center py-10 opacity-50">
                  <p className="text-sm">Panduan tidak ditemukan.</p>
                </div>
              )}
            </div>
          </div>
        );

      case "map":
        return (
          <div
            className="h-full overflow-y-auto px-6 py-6"
            style={{ backgroundColor: colors.bg, color: colors.text }}
          >
            <div className="mb-6">
              <p className="text-xs font-bold text-orange-500 uppercase tracking-widest mb-1">
                Jejaring Keselamatan Lokal
              </p>
              <h2 className="text-xl font-bold leading-tight">
                RADAR SIAGA & EVAKUASI
              </h2>
              <div className="flex items-center space-x-2 mt-1">
                <span className="text-sm opacity-60 font-medium tracking-wide">
                  Radius 5KM
                </span>
                <span className="bg-green-600 text-white px-2 py-0.5 rounded text-[10px] font-bold uppercase">
                  Aktif
                </span>
              </div>
            </div>

            <div
              className="relative rounded-3xl p-6 border mb-6 shadow-sm"
              style={{
                backgroundColor: colors.card,
                borderColor: colors.border,
              }}
            >
              <div className="aspect-square w-full grid grid-cols-6 grid-rows-6 gap-0 relative overflow-hidden rounded-2xl bg-[#0d1b3e]">
                {[...Array(36)].map((_, i) => (
                  <div key={i} className="border-[0.5px] border-white/10"></div>
                ))}

                {/* Posisi Pengguna */}
                <div className="absolute top-[45%] left-[45%] bg-orange-600 text-white p-1.5 rounded-full shadow-[0_0_15px_rgba(255,116,24,0.6)] z-10">
                  <User size={16} />
                </div>

                {/* Relawan Komunitas */}
                <div className="absolute top-[20%] left-[20%] bg-blue-500 text-white px-2 py-1 rounded-full text-[10px] font-bold flex items-center gap-1 shadow-sm">
                  <Heart size={10} /> Relawan
                </div>
                <div className="absolute bottom-[30%] right-[15%] bg-blue-500 text-white px-2 py-1 rounded-full text-[10px] font-bold flex items-center gap-1 shadow-sm">
                  <Heart size={10} /> Relawan
                </div>

                {/* Titik Kumpul / Fasilitas */}
                <div className="absolute top-[10%] right-[20%] bg-green-500 text-white px-2 py-1 rounded-full text-[10px] font-bold flex items-center gap-1 shadow-sm">
                  <ShieldCheck size={10} /> Titik Kumpul
                </div>
                <div className="absolute bottom-[20%] left-[15%] bg-white text-black px-2 py-1 rounded-full text-[10px] font-bold flex items-center gap-1 shadow-sm">
                  <Activity size={10} color="red" /> Klinik
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 mt-6">
                <div className="flex items-start space-x-2">
                  <MapPin size={16} className="text-gray-500 mt-1" />
                  <div>
                    <p className="text-[10px] opacity-50 font-bold uppercase">
                      Lokasi Anda
                    </p>
                    <p className="text-xs font-bold truncate">Lhoknga, Aceh</p>
                  </div>
                </div>
                <div className="flex items-start space-x-2">
                  <Users size={16} className="text-gray-500 mt-1" />
                  <div>
                    <p className="text-[10px] opacity-50 font-bold uppercase">
                      Relawan Siaga
                    </p>
                    <p className="text-xs font-bold">12 di sekitar</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-3 mb-6">
              <h3 className="text-xs font-bold uppercase tracking-widest opacity-60">
                Status Transmisi (Simulasi SOS)
              </h3>
              <div className="space-y-2">
                <div
                  className="p-3 rounded-2xl border flex items-center gap-3 text-sm font-medium"
                  style={{
                    backgroundColor: colors.card,
                    borderColor: colors.border,
                  }}
                >
                  <div className="w-2 h-2 rounded-full bg-green-500"></div>
                  Koordinat GPS Terkunci (Akurasi 3m)
                </div>
                <div
                  className="p-3 rounded-2xl border flex items-center gap-3 text-sm font-medium"
                  style={{
                    backgroundColor: colors.card,
                    borderColor: colors.border,
                  }}
                >
                  <div className="w-2 h-2 rounded-full bg-yellow-500 animate-pulse"></div>
                  Menyiarkan ke relawan radius 5KM...
                </div>
                <div
                  className="p-3 rounded-2xl border flex items-center gap-3 text-sm font-medium opacity-50"
                  style={{
                    backgroundColor: colors.card,
                    borderColor: colors.border,
                  }}
                >
                  <div className="w-2 h-2 rounded-full bg-gray-500"></div>
                  Menunggu respons Command Center 112
                </div>
              </div>
            </div>
          </div>
        );

      case "profile":
        return (
          <div
            className="h-full overflow-y-auto pb-10 px-6 pt-10"
            style={{ backgroundColor: colors.bg, color: colors.text }}
          >
            <h1 className="text-2xl font-bold mb-6">Profil Pengguna</h1>

            <div
              className="flex items-center space-x-4 p-5 rounded-3xl mb-6 shadow-sm"
              style={{ backgroundColor: colors.card }}
            >
              <div className="relative">
                <div className="w-16 h-16 bg-blue-900/40 rounded-full flex items-center justify-center overflow-hidden border border-white/10">
                  <User size={32} color={isDarkMode ? "#9ca3af" : "#475569"} />
                </div>
                <div className="absolute bottom-0 right-0 bg-green-500 border-2 border-white dark:border-black p-1 rounded-full">
                  <ShieldCheck size={12} color="white" />
                </div>
              </div>
              <div>
                <h2 className="text-xl font-bold">Budi Santoso</h2>
                <p className="text-xs opacity-50 font-mono">ID: SK-2983-4412</p>
              </div>
            </div>

            <div
              className="rounded-3xl p-6 mb-6 border relative overflow-hidden shadow-sm"
              style={{
                backgroundColor: isDarkMode ? "#1a2c5a" : "#ffffff",
                borderColor: isDarkMode
                  ? "rgba(255,116,24,0.2)"
                  : "rgba(255,116,24,0.1)",
              }}
            >
              <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-orange-500 to-red-600"></div>
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-2">
                  <Fingerprint className="text-red-500" size={20} />
                  <h3 className="font-bold text-red-500 uppercase text-xs tracking-tight">
                    Biometric Safety Ledger
                  </h3>
                </div>
                <ShieldCheck size={18} className="opacity-40" />
              </div>

              <div className="grid grid-cols-2 gap-4 mb-6">
                <div
                  className="p-4 rounded-2xl text-center shadow-inner"
                  style={{
                    backgroundColor: isDarkMode
                      ? "rgba(255,255,255,0.03)"
                      : "rgba(0,0,0,0.02)",
                  }}
                >
                  <span className="text-[10px] opacity-50 uppercase block mb-1">
                    Golongan Darah
                  </span>
                  <span className="text-lg font-bold leading-tight">
                    O Positif
                  </span>
                </div>
                <div
                  className="p-4 rounded-2xl text-center shadow-inner"
                  style={{
                    backgroundColor: isDarkMode
                      ? "rgba(255,255,255,0.03)"
                      : "rgba(0,0,0,0.02)",
                  }}
                >
                  <span className="text-[10px] opacity-50 uppercase block mb-1">
                    Berat / Tinggi
                  </span>
                  <span className="text-lg font-bold leading-tight break-all">
                    70kg / 175 cm
                  </span>
                </div>
              </div>

              <div className="space-y-4">
                <div className="flex items-start space-x-3">
                  <AlertCircle size={16} className="text-orange-500 mt-0.5" />
                  <div>
                    <span className="text-[10px] opacity-50 uppercase block">
                      Alergi Utama
                    </span>
                    <p className="text-sm font-semibold">Penisilin, Kacang</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <Activity size={16} className="text-blue-500 mt-0.5" />
                  <div>
                    <span className="text-[10px] opacity-50 uppercase block">
                      Riwayat Medis
                    </span>
                    <p className="text-sm font-semibold">Asma Ringan</p>
                  </div>
                </div>
              </div>
            </div>

            <div
              className="rounded-3xl p-6 mb-4 shadow-sm"
              style={{ backgroundColor: colors.card }}
            >
              <h3 className="font-bold mb-4 flex items-center space-x-2">
                <Heart size={18} className="text-red-500" />
                <span>Kontak Darurat</span>
              </h3>
              <div className="space-y-4">
                <div
                  className="flex items-center justify-between p-3 rounded-2xl border"
                  style={{ borderColor: colors.border }}
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                      <User size={18} className="text-blue-600" />
                    </div>
                    <div>
                      <p className="text-xs font-bold">Siti Aminah (Istri)</p>
                      <p className="text-[10px] opacity-60">0812-3456-7890</p>
                    </div>
                  </div>
                  <button className="p-2 rounded-full bg-green-500/10 text-green-500">
                    <PhoneCall size={16} />
                  </button>
                </div>
              </div>
            </div>

            <div
              className="rounded-3xl p-6 shadow-sm mb-10"
              style={{ backgroundColor: colors.card }}
            >
              <h3 className="font-bold mb-4">Dukungan SiagaKita</h3>
              <div className="space-y-4">
                <div className="flex items-center space-x-3 opacity-80">
                  <Mail size={16} className="text-orange-500" />
                  <span className="text-xs font-medium">
                    bantuan@siagakita.id
                  </span>
                </div>
                <div className="flex items-center space-x-3 opacity-80">
                  <Phone size={16} className="text-orange-500" />
                  <span className="text-xs font-medium">
                    Pusat Panggilan: 112 (Darurat)
                  </span>
                </div>
              </div>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="flex justify-center items-center h-screen bg-gray-300 p-4 font-sans antialiased">
      <div
        className="w-full max-w-[390px] rounded-[3.5rem] shadow-[0_40px_100px_rgba(0,0,0,0.3)] border-[10px] border-gray-900 relative overflow-hidden flex flex-col transition-colors duration-500"
        style={{ backgroundColor: colors.bg, height: "min(844px, 92vh)" }}
      >
        {/* Notch */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-36 h-8 bg-gray-900 rounded-b-[1.5rem] z-50"></div>

        {/* Popup SOS di dalam layar HP, di bawah notch */}
        {showSOSAlert && (
          <div className="absolute top-12 left-4 right-4 bg-[#ff7418] text-white p-4 rounded-2xl z-[100] font-bold text-center text-sm shadow-[0_10px_25px_rgba(255,116,24,0.4)] animate-in slide-in-from-top-4 fade-in duration-300">
            SINYAL SOS TERKIRIM!
            <br />
            <span className="text-[11px] font-medium opacity-90">
              Bantuan sedang diarahkan ke lokasi Anda.
            </span>
          </div>
        )}

        <div className="flex-1 overflow-hidden">{renderContent()}</div>

        {/* Navigation */}
        <div
          className="h-24 backdrop-blur-xl border-t flex items-center justify-around px-2 z-40 pb-4"
          style={{
            backgroundColor: `${colors.card}F0`,
            borderColor: colors.border,
          }}
        >
          {[
            { id: "home", icon: ShieldCheck, label: "Beranda" },
            { id: "guide", icon: BookOpen, label: "Panduan" },
            { id: "map", icon: MapIcon, label: "Map" },
            { id: "profile", icon: User, label: "Profil" },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex flex-col items-center justify-center w-1/4 h-full transition-all ${
                activeTab === tab.id ? "scale-110" : "opacity-40"
              }`}
            >
              <tab.icon
                size={24}
                color={activeTab === tab.id ? colors.primary : colors.text}
              />
              <span
                className={`text-[10px] mt-1 font-bold ${
                  activeTab === tab.id ? "text-orange-500" : ""
                }`}
                style={{
                  color: activeTab === tab.id ? colors.primary : colors.text,
                }}
              >
                {tab.label}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default App;
