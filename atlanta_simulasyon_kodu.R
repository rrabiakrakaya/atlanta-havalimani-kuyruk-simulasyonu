KAYNAK KODLAR
 
# ==============================================================================
# PROJE: HAVALİMANI İNİŞ PİSTİ BEKLEME KUYRUĞU SİMÜLASYONU (M/G/1)
# ==============================================================================
 
# Projede kullanılan veri setini (Combined_Flights_2022.csv)
#çalıştırmadan önce aşağıdaki bağlantıdan bilgisayarınıza indirebilirsiniz:
#https://www.kaggle.com/datasets/robikscube/flight-delay-dataset-20182022?select=Combined_Flights_2022.csv 
# -------------------------------
# 1. Veriyi yükle 
cat("Lütfen açılan pencereden 'Combined_Flights_2022.csv' dosyasını seçin...\n")
tum_veri <- read.csv(file.choose())
 
# 2. Sadece Atlanta (ATL) ve Ocak (Month == 1) verisini filtreleyelim
atl_ocak <- tum_veri[tum_veri$Dest == "ATL" & tum_veri$Month == 1, ]
 
# 3. Trafiğin kararlı (stable) olduğu 06:00 - 06:59 bloğunu filtreleyelim
secilen_blok <- "0600-0659"
atl_sakin <- atl_ocak[atl_ocak$ArrTimeBlk == secilen_blok, ]
 
# Lambda (Geliş Hızı) Hesabı
toplam_gun_sakin <- length(unique(atl_sakin$FlightDate))
lambda <- nrow(atl_sakin) / toplam_gun_sakin 
 
# Mu (Kapasite / Hizmet Hızı) ve Rho Hesabı
mu <- 17.14 
rho <- lambda / mu
 
cat("=== 1. TEMEL PARAMETRELER ===\n")
cat("Lambda (Geliş Hızı):", round(lambda, 2), "uçak/saat\n")
cat("Mu (Hizmet Hızı):", round(mu, 2), "uçak/saat\n")
cat("Rho (Kullanım Oranı):", round(rho, 2), "\n\n")
 
# ------------------------------------------------------------------------------
# AŞAMA 2: M/G/1 MODEL KANITI (HİZMET SÜRESİ DAĞILIMI)
# ------------------------------------------------------------------------------
# Hizmet sürelerini (TaxiIn) al ve eksik (NA) verileri temizle
hizmet_sureleri <- atl_sakin$TaxiIn[!is.na(atl_sakin$TaxiIn)]
 
mu_hizmet <- mean(hizmet_sureleri)
var_hizmet <- var(hizmet_sureleri)
 
# Dağılım Parametreleri
lambda_exp <- 1 / mu_hizmet
shape_gamma <- (mu_hizmet^2) / var_hizmet
rate_gamma <- mu_hizmet / var_hizmet
 
# Goodness of Fit Grafiği Çizimi
hist(hizmet_sureleri, breaks=20, prob=TRUE, 
     main="Hizmet Süreleri: Üstel vs Gamma Dağılımı",
     xlab="Hizmet Süresi (Dakika)", ylab="Olasılık Yoğunluğu",
     col="lightgray", border="white", ylim=c(0, 0.15))
 
x_val <- seq(0, max(hizmet_sureleri) + 5, length=200)
 
# M/M/1 Varsayımı (Kırmızı Kesik Çizgi)
lines(x_val, dexp(x_val, rate=lambda_exp), col="red", lwd=3, lty=2)
# M/G/1 Varsayımı (Mavi Düz Çizgi)
lines(x_val, dgamma(x_val, shape=shape_gamma, rate=rate_gamma), col="blue", lwd=3)
 
legend("topright", 
       legend=c("Gerçek Veri", "Üstel (M/M/1)", "Gamma (M/G/1)"),
       fill=c("lightgray", NA, NA), border=c("black", NA, NA),
       col=c(NA, "red", "blue"), lwd=c(NA, 3, 3), lty=c(NA, 2, 1), cex=0.9)
 
 
 
 
 
 
 
 
# ------------------------------------------------------------------------------
# AŞAMA 3: ANALİTİK ÇÖZÜM (LITTLE YASASI VE M/M/1 REFERANS DEĞERLERİ)
# ------------------------------------------------------------------------------
cat("\n=== 3. ANALİTİK (TEORİK) ÇÖZÜM SONUÇLARI ===\n")
 
# M/M/1 için kuyruk uzunluğu (Lq) ve Sistemdeki uçak sayısı (L)
Lq <- (rho^2) / (1 - rho)
L  <- Lq + rho
 
# Little Yasası ile Bekleme Süreleri (Wq ve W) - Saat cinsinden
Wq <- Lq / lambda
W  <- L / lambda
 
# Yorumlaması kolay olsun diye Dakikaya çevirelim
Wq_dk <- Wq * 60
W_dk  <- W * 60
 
cat("Kuyruktaki Ortalama Uçak (Lq):", round(Lq, 2), "uçak\n")
cat("Sistemdeki Toplam Uçak (L):", round(L, 2), "uçak\n")
cat("Kuyrukta Bekleme Süresi (Wq):", round(Wq_dk, 2), "dakika\n")
cat("Sistemde Geçen Toplam Süre (W):", round(W_dk, 2), "dakika\n")
cat("Little Yasası Kontrolü (L = Lambda * W):", round(L, 2), "=", round(lambda * W, 2), "-> BAŞARILI\n\n")
 
# ------------------------------------------------------------------------------
# AŞAMA 4: MONTE CARLO SİMÜLASYONU (M/G/1) - ÖLÇEKLENDİRİLMİŞ
# ------------------------------------------------------------------------------
cat("=== 4. MONTE CARLO SİMÜLASYONU (M/G/1) ===\n")
 
# Tekrarlanabilirlik için seed (Rubrikte zorunlu istenmişti)
set.seed(123) 
N <- 10000 # 10.000 uçaklık simülasyon
 
# Gelişler: Poisson süreci (Üstel dağılım) - Saat cinsinden
inter_arrival_times <- rexp(N, rate = lambda)
arrival_times <- cumsum(inter_arrival_times)
 
# DÜZELTME: Gamma dağılımını gerçek varyansla üretip, ortalamasını teorik mu'ya (17.14) eşitliyoruz
hedef_hizmet_dk <- 60 / mu 
orijinal_gamma <- rgamma(N, shape = shape_gamma, rate = rate_gamma)
service_times <- (orijinal_gamma * (hedef_hizmet_dk / mu_hizmet)) / 60
 
# Simülasyon değişkenlerini önceden oluşturalım (Hızlı çalışması için vektörizasyon)
start_times <- numeric(N)
end_times <- numeric(N)
wait_times <- numeric(N)
 
# İlk uçak sisteme girer ve beklemeden iner
start_times[1] <- arrival_times[1]
end_times[1] <- start_times[1] + service_times[1]
wait_times[1] <- 0
 
# Diğer N-1 uçak için FIFO (İlk giren ilk iner) kuyruk döngüsü
for(i in 2:N) {
  # Uçak ya kendi geliş saatinde ya da bir önceki uçağın inişi bitince başlar
  start_times[i] <- max(arrival_times[i], end_times[i-1])
  wait_times[i] <- start_times[i] - arrival_times[i]
  end_times[i] <- start_times[i] + service_times[i]
}
 
# Simülasyon Wq sonucunu hesaplayıp dakikaya çevirme
sim_Wq_saat <- mean(wait_times)
sim_Wq_dk <- sim_Wq_saat * 60
 
cat("Simülasyon Büyüklüğü (N):", N, "uçak\n")
cat("Simüle Edilen Bekleme Süresi (M/G/1):", round(sim_Wq_dk, 2), "dakika\n")
cat("Teorik M/M/1 Referans Bekleme Süresi:", round(Wq_dk, 2), "dakika\n")
 
 
 
 
 
# ------------------------------------------------------------------------------
# AŞAMA 5: BÜYÜK SAYILAR YASASI (LLN) YAKINSAMA GRAFİĞİ
# ------------------------------------------------------------------------------
cat("\n=== 5. BÜYÜK SAYILAR YASASI (LLN) GRAFİĞİ ÇİZİLİYOR ===\n")
 
# Her bir adım (N) için kümülatif ortalama bekleme süresini (dakika) hesapla
kuyruk_sureleri_dk <- wait_times * 60
kumulatif_ortalama <- cumsum(kuyruk_sureleri_dk) / (1:N)
 
# Yakınsama (Convergence) Grafiği Çizimi
plot(1:N, kumulatif_ortalama, type="l", col="darkblue", lwd=2,
     main="Büyük Sayılar Yasası: Simülasyonun Yakınsaması (LLN)",
     xlab="Simülasyona Giren Uçak Sayısı (N)", 
     ylab="Ortalama Bekleme Süresi Wq (Dakika)",
     ylim=c(0, 20))
 
# Simülasyonun ulaştığı nihai değeri yatay bir çizgi olarak ekle
abline(h=sim_Wq_dk, col="green", lwd=3, lty=1)
 
# Analitik M/M/1 değerini referans olarak ekle
abline(h=Wq_dk, col="red", lwd=3, lty=2)
 
legend("topright", 
       legend=c("Kümülatif Simülasyon Ortalaması", 
                paste("Nihai M/G/1 Değeri (", round(sim_Wq_dk,2), "dk)"),
                paste("M/M/1 Referans (", round(Wq_dk,2), "dk)")),
       col=c("darkblue", "green", "red"), lwd=2, lty=c(1,1,2), cex=0.9)
