# Installation & Basic Usage

## 1. ImageJ / Fiji 준비

- Fiji (ImageJ 배포판) 또는 최신 ImageJ 버전을 사용합니다.
- 다채널(confocal, widefield 등) 이미지를 다룰 수 있는지 확인하세요.

## 2. 매크로 파일 위치

이 사이트의 매크로 예시는 다음 경로에 저장되어 있습니다.

- `docs/assets/macros/non-scaled_multichannel_plot.ijm`
- `docs/assets/macros/scaled_multichannel_plot.ijm`

GitHub 레포지토리로 올린 뒤에는 각 매크로 페이지에 있는 **Download macro** 링크를 눌러 `.ijm` 파일을 저장할 수 있습니다.

ImageJ/Fiji에서 매크로를 사용하려면 보통 다음 중 한 가지 방법을 씁니다.

1. `Plugins > Macros > Run...` 을 선택하고 `.ijm` 파일을 직접 선택해서 실행
2. `Plugins > Macros > Edit...` 으로 매크로 에디터를 열고 코드를 붙여 넣은 후, `File > Save As...` 를 이용해 `ImageJ/macros` 폴더에 저장

둘 중 편한 방식을 선택해 사용하시면 됩니다.

## 3. 새 매크로를 추가할 때

새로운 매크로를 추가하고 싶다면:

1. `docs/assets/macros/` 폴더에 `.ijm` 파일을 추가하고
2. `docs/` 안에 새로운 `.md` 파일을 만들어 사용법과 예시를 작성한 후
3. `mkdocs.yml` 의 `nav` 섹션에 해당 페이지를 추가합니다.

이렇게 하면 GitHub Pages에서 자동으로 메뉴에 반영됩니다.

