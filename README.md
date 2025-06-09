# Re:Live

**Re:Live**는 건강검진 결과지를 OCR로 스캔해 디지털화하고, 검사 수치를 연도별 그래프로 시각화하여 관리할 수 있도록 돕는 iOS 앱입니다. Apple의 VisionKit을 활용해 혈액, 소변, 대변, 조직 검사 등 주요 건강 수치를 자동 추출하고 저장합니다.

---

## 프로젝트 목적

- 종이 건강기록의 분실 방지 및 통합 관리
- 연도별 건강 추이 시각화를 통한 자기 관리 도구 제공
- 비정형 결과지를 정형화하여 앱 내부 데이터베이스화

---

## 핵심 기능 (MVP 기준)

- Apple VisionKit을 활용한 OCR 스캔
- 주요 검사 항목 자동 추출 및 직접 편집 기능
- 연도별 수치 그래프 (선형, 바 차트)
- 검사 기록의 항목별 분류 및 검색 기능

---

## 기술 스택

- Swift 5, UIKit 기반 iOS 앱
- MVVM 아키텍처 적용
- OCR: Apple VisionKit
- 데이터 저장: CoreData (Firebase 연동 계획 중)
- 차트 시각화: Swift Charts 또는 Charts 라이브러리
- Xcode 15 이상, iOS 16 이상 대응

---

## 폴더 구조
```
re-live/
├── Views/                       # UIKit 기반의 ViewController 및 커스텀 뷰
│   ├── Home/
│   │   ├── HomeViewController.swift
│   │   └── SummaryStatCardView.swift
│   ├── Scan/
│   │   ├── ScanViewController.swift
│   │   └── OCRCameraOverlayView.swift
│   ├── Edit/
│   │   ├── EditResultViewController.swift
│   │   └── EditableTestItemCell.swift
│   ├── Records/
│   │   ├── RecordListViewController.swift
│   │   └── RecordCardView.swift
│   └── Graphs/
│       ├── GraphViewController.swift
│       └── GraphChartView.swift
├── ViewModels/                 # MVVM 아키텍처의 각 화면별 ViewModel
│   ├── Home/
│   │   └── HomeViewModel.swift
│   ├── Scan/
│   │   └── ScanViewModel.swift
│   ├── Edit/
│   │   └── EditViewModel.swift
│   ├── Records/
│   │   └── RecordListViewModel.swift
│   └── Graphs/
│       └── GraphViewModel.swift
├── Models/                     # 도메인 모델 및 열거형(enum) 정의
│   ├── Enum/
│   │   └── TestType.swift
│   ├── HealthRecord.swift
│   ├── OCRResult.swift
│   └── TestItem.swift
├── Services/                   # 비즈니스 로직 처리용 서비스 계층
│   ├── OCRService.swift
│   ├── LocalStorageService.swift
│   └── FirebaseService.swift
├── Resources/                  # 색상, 폰트, 에셋 등 리소스 모음
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── Assets.xcassets/
└── Support/                    # 앱 생명주기, 코디네이터, 공용 유틸리티 등
    ├── App/
    │   ├── AppDelegate.swift
    │   ├── SceneDelegate.swift
    │   └── ViewController.swift
    ├── Constants/
    │   └── Metric.swift
    ├── Coordinates/            # 중·대형 앱으로 확장 예정으로, MVVM-C 구조 채택
    │   └── AppCoordinator.swift
    ├── Extensions/
    │   └── UIView+Extension.swift
    └── Helpers/
        └── DateFormatterHelper.swift

```

---

## 브랜치 전략

- `main`: 배포용 안정 코드
- `dev`: 통합 개발 브랜치
- `feature/*`: 기능 단위 개발 브랜치  
  예: `feature/scan-ocr`, `feature/graph-visualization`

---

## 커밋 컨벤션

형식: `<type>: <설명>` (영문 소문자)

예시:  
add: implement OCR parsing for ALT/AST  
fix: resolve layout issue in ScanViewController

타입 목록:
- `add`: 신규 파일 또는 기능 추가
- `fix`: 버그 수정
- `refactor`: 리팩토링 (기능 변경 없음)
- `chore`: 문서, 설정 등 기타 변경

---

## 향후 계획

- Firebase 기반 백업/복구 기능
- AI 기반 건강 분석 기능 연계
- EMR 시스템 연동 가능성 검토

---

## 개발자

김보미  
GitHub: https://github.com/bomirgasm  
Email: bomirgasm@gmail.com


---
---
___  




# Re:Live

**Re:Live** is an iOS application that digitizes medical test reports using OCR and helps users manage their health data by visualizing test results over time. Built with Apple's VisionKit, the app automatically extracts and stores key health indicators such as blood, urine, stool, and tissue test values.

---

## Project Purpose

- Prevent loss of physical health records and enable centralized management
- Provide self-monitoring tools through year-by-year health trend visualization
- Standardize unstructured test results into a structured in-app database

---

## Key Features (based on MVP)

- OCR scanning with Apple VisionKit
- Automatic extraction and manual editing of major test items
- Year-over-year health data visualization (line and bar charts)
- Categorization and search functionality for test records

---

## Tech Stack

- Swift 5, UIKit-based iOS app
- MVVM architecture
- OCR: Apple VisionKit
- Data storage: CoreData (Firebase integration planned)
- Charting: Swift Charts or third-party Charts library
- Xcode 15 or later, iOS 16+

---

## Folder Structure

```text
re-live/
├── Views/                       # UIKit ViewControllers and custom views
│   ├── Home/
│   │   ├── HomeViewController.swift
│   │   └── SummaryStatCardView.swift
│   ├── Scan/
│   │   ├── ScanViewController.swift
│   │   └── OCRCameraOverlayView.swift
│   ├── Edit/
│   │   ├── EditResultViewController.swift
│   │   └── EditableTestItemCell.swift
│   ├── Records/
│   │   ├── RecordListViewController.swift
│   │   └── RecordCardView.swift
│   └── Graphs/
│       ├── GraphViewController.swift
│       └── GraphChartView.swift
├── ViewModels/                 # MVVM ViewModels per screen
│   ├── Home/
│   │   └── HomeViewModel.swift
│   ├── Scan/
│   │   └── ScanViewModel.swift
│   ├── Edit/
│   │   └── EditViewModel.swift
│   ├── Records/
│   │   └── RecordListViewModel.swift
│   └── Graphs/
│       └── GraphViewModel.swift
├── Models/                     # Domain models and enums
│   ├── Enum/
│   │   └── TestType.swift
│   ├── HealthRecord.swift
│   ├── OCRResult.swift
│   └── TestItem.swift
├── Services/                   # Business logic services
│   ├── OCRService.swift
│   ├── LocalStorageService.swift
│   └── FirebaseService.swift
├── Resources/                  # Fonts, colors, assets
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── Assets.xcassets/
└── Support/                    # App lifecycle, coordinators, utilities
    ├── App/
    │   ├── AppDelegate.swift
    │   ├── SceneDelegate.swift
    │   └── ViewController.swift
    ├── Constants/
    │   └── Metric.swift
    ├── Coordinates/
    │   └── AppCoordinator.swift
    ├── Extensions/
    │   └── UIView+Extension.swift
    └── Helpers/
        └── DateFormatterHelper.swift

```


---

## Branch Strategy

- `main`: stable production-ready code
- `dev`: development integration branch
- `feature/*`: feature-specific branches  
  Example: `feature/scan-ocr`, `feature/graph-visualization`

---

## Commit Convention

Format: `<type>: <description>` (use lowercase English)

Examples:  
add: implement OCR parsing for ALT/AST  
fix: resolve layout issue in ScanViewController


Supported types:
- `add`: new files or features
- `fix`: bug fixes
- `refactor`: code restructuring without feature changes
- `chore`: configuration or documentation updates

---

## Future Plans

- Firebase backup and synchronization
- Integration with AI-based health advisors
- Potential EMR system compatibility

---

## Developer

**Suzie Kim**  
GitHub: [@bomirgasm](https://github.com/bomirgasm)  
Email: bomirgasm@gmail.com

