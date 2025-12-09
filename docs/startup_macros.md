# Startup Macros (F-keys & Channel Shortcuts)

이 파일은 Fiji/ImageJ가 시작될 때 자동으로 로드되는
`StartupMacros.fiji.ijm` 의 커스텀 버전입니다.

기본 StartupMacros 내용 위에, 다음과 같은 단축키를 추가해 두었습니다.

## 1. F 키 단축키

- **F1**: `Copy Channel Colors/LUT from Image1 to Image2...`
  - 현재 열려 있는 이미지 중 Source/Target 을 고르고,
    채널 색상, LUT, display range, active channels 등을 한 번에 복사합니다.
  - 기능은 별도 매크로인 `Copy_Channel_Colors_LUT.ijm` 과 동일합니다.
- **F2**: `Close all...`
  - 열린 모든 이미지를 한 번에 닫습니다.

## 2. 숫자 키 (1–6): 단일 채널 보기

각 키는 해당 채널 하나만 **color mode** 로 표시하도록 설정합니다.

- **1**: 채널 1만 표시  
- **2**: 채널 2만 표시  
- **3**: 채널 3만 표시  
- **4**: 채널 4만 표시  
- **5**: 채널 5만 표시  
- **6**: 채널 6만 표시  

매크로 내부에서는 `"Close all... [1]"` 같은 이름이지만,
실제 동작은 `Stack.setDisplayMode("color"); Stack.setChannel(N);` 입니다.

## 3. 7, 8 키: Composite view 설정

- **7**:
  - `Property.set("CompositeProjection", "Sum");`
  - `Stack.setDisplayMode("composite");`
  - `Stack.setActiveChannels("11110");`
  - 즉, 앞의 4개 채널만 활성화된 composite view 를 빠르게 띄웁니다.
- **8**:
  - `Property.set("CompositeProjection", "Sum");`
  - `Stack.setDisplayMode("composite");`
  - `Stack.setActiveChannels("111111");`
  - 모든 채널이 켜진 composite view 로 전환합니다.

## 4. 설치 방법

1. 이 파일을 다운로드합니다.  
   - [Download StartupMacros.fiji.ijm](assets/macros/StartupMacros.fiji.ijm)
2. Fiji 설치 폴더 안의 `macros` 폴더를 찾습니다.
   - 예: `Fiji.app/macros/`
3. 기존 `StartupMacros.fiji.ijm` 또는 `StartupMacros.txt` 가 있다면
   백업해 둔 뒤, 이 파일을 같은 이름으로 복사합니다.
4. Fiji/ImageJ를 재시작하면 새 단축키가 활성화됩니다.

> 주의: 다른 StartupMacros 설정을 이미 사용 중이라면,  
> 이 파일의 하단에 있는 단축키 정의 부분만 가져다가
> 직접 기존 파일에 병합하는 것을 추천합니다.

