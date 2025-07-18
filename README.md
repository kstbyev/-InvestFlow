# InvestFlow

InvestFlow - это iOS приложение для отслеживания акций и управления инвестиционным портфелем.

## Зависимости

Проект использует Swift Package Manager для управления зависимостями:

- **SnapKit** (5.6.0) - для программного создания Auto Layout констрейнтов

## Требования

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/kstbyev/-InvestFlow.git
```

2. Откройте `InvestFlow.xcodeproj` в Xcode

3. Подождите, пока Xcode автоматически установит все зависимости через Swift Package Manager

4. Соберите и запустите проект (⌘ + R)

## Архитектура

Проект использует MVVM архитектуру и построен с использованием:
- UIKit + SwiftUI для UI
- URLSession для сетевых запросов
- UserDefaults для хранения избранного
- SnapKit для верстки

## Основные функции

- 📊 Просмотр списка акций с актуальными ценами
- 🔍 Поиск акций по названию или тикеру
- ⭐️ Добавление акций в избранное
- 💾 Локальное сохранение избранных акций
- 📱 Адаптивный дизайн
- ✨ Плавные анимации переходов

## Скриншоты

### List 
<p align="center">
  <img src="https://github.com/user-attachments/assets/5f9a24e9-6de6-4f41-86ee-f3ffab087522" width="200" alt="Home Screen">
</p>

### Scrolled List
<p align="center">
  <img src="https://github.com/user-attachments/assets/3687969b-eb2e-4bce-b82c-4fb922edfeb7" width="200" alt="Scrolled List">
</p>

### List (Favourite)
<p align="center">
  <img src="https://github.com/user-attachments/assets/b2084155-69d3-4a4d-a504-540d480da795" width="200" alt="List (Favourite)">
</p>

### Search (Empty)
<p align="center">
  <img src="https://github.com/user-attachments/assets/547615fb-2964-44ed-94a5-250ed1d4e558" width="200" alt="Search (Empty)">
</p>

### Search (Result)
<p align="center">
  <img src="https://github.com/user-attachments/assets/d89e2eb9-e8f9-40e2-abd0-2866c94f99c0" width="200" alt="Search (Result)">
</p>



## Лицензия

MIT License
