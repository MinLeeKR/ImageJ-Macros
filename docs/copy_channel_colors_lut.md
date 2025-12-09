# Copy Channel Colors/LUT between Images

이 매크로는 한 ImageJ 이미지의 **채널 색상과 LUT 설정**을
다른 이미지로 복사해 주는 유틸리티입니다.

Composite 모드에서 채널별 색을 맞춰 놓은 후,
비슷한 구조의 다른 이미지에 같은 색/밝기 설정을 그대로 적용하고 싶을 때 유용합니다.

## 기능 요약

- 열려 있는 이미지들 중에서 **Source (from)** / **Target (to)** 를 선택
- 채널별 LUT (색상) 복사
- 옵션에 따라:
  - 각 채널의 display range (Brightness/Contrast) 복사
  - 활성 채널(보이는 채널) 패턴 복사
  - 두 이미지를 강제로 Composite 모드로 전환
- 채널 수가 다를 경우, **앞에서부터 공통 부분만** 복사

## 사용 방법

1. ImageJ/Fiji에서 최소 두 개 이상의 이미지를 엽니다.  
   (같은 채널 구조를 가진 이미지일수록 결과가 직관적입니다.)
2. 메뉴에서 매크로를 실행합니다:  
   `Plugins > Macros > Run...` → `Copy_Channel_Colors_LUT.ijm` 선택
3. 다이얼로그에서 다음을 설정합니다.
   - **Source (from)**: LUT와 범위를 가져올 이미지
   - **Target (to)**: 설정을 적용할 이미지
   - **Copy display ranges**: 밝기/대비 설정까지 같이 복사할지 여부
   - **Copy channel visibility**: 보이는 채널 패턴(예: 1011)을 복사할지 여부
   - **Force Composite mode on both**: 두 이미지를 Composite 모드로 맞출지 여부
4. `OK` 를 누르면 선택된 채널 수만큼 설정이 복사됩니다.

## 출력/로그

매크로 실행 후 **Log** 창에 다음과 같은 메시지가 출력됩니다.

- 몇 개의 채널이 복사되었는지
- Source/Target 의 채널 수가 다를 경우, 앞의 몇 개만 복사했는지 안내

## 매크로 다운로드

- [Download macro (.ijm)](assets/macros/Copy_Channel_Colors_LUT.ijm)



