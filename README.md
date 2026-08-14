# ✈️ Atlanta (ATL) Havalimanı İniş Pisti Bekleme Kuyruğu Simülasyonu

Bu proje, dünyanın en yoğun havalimanlarından biri olan Atlanta Hartsfield-Jackson Havalimanı'nın sabah yoğunluğundaki (06:00–06:59) iniş pisti kapasitesini **Kuyruk Teorisi** ve **Monte Carlo Simülasyonu** kullanarak analiz etmektedir.

## 🎯 Projenin Amacı 
Gerçek dünya operasyonlarında hizmet süreleri her zaman standart (üstel) dağılım göstermez. Bu çalışmanın amacı, hizmet süresindeki varyansın sistemdeki bekleme süreleri üzerindeki doğrudan etkisini istatistiksel olarak ölçmektir. 

2022 yılına ait gerçek uçuş verileri üzerinden yapılan analizde şu çarpıcı sonuçlar elde edilmiştir:
* Klasik analitik **M/M/1** varsayımı, ortalama bekleme süresini (Wq) **13.21 dakika** olarak hesaplamaktadır.
* Ancak verinin gerçek dağılımına (Gamma) uygun olarak kurulan 10.000 iterasyonluk **M/G/1 Monte Carlo Simülasyonu**, gerçek bekleme süresinin **8.13 dakika** olduğunu kanıtlamıştır.
* Ortaya çıkan bu **%38'lik fark**, hizmet süresi varyansının operasyonel planlamada ve kapasite yönetiminde ne kadar kritik bir rol oynadığını göstermektedir.

## 🛠️ Kullanılan Teknolojiler ve Yöntemler
* **Programlama Dili:** R
* **Modeller:** M/M/1 ve M/G/1 Kuyruk Modelleri, Pollaczek-Khinchine Formülü
* **İstatistiksel Yaklaşımlar:** Monte Carlo Simülasyonu, Büyük Sayılar Yasası Yakınsaması, Dağılım Uyumu

