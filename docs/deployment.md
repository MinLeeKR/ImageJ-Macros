# Deploying to GitHub Pages

이 레포지토리는 MkDocs + GitHub Pages 를 사용해
ImageJ 매크로 문서를 정적 웹사이트로 배포합니다.

이미 `.github/workflows/publish.yml` 가 설정되어 있어  
`main` 브랜치에 push 하면 자동으로 사이트가 업데이트됩니다.

## 1. 로컬 환경에서 사이트 미리보기

1. 레포지토리를 클론합니다.

```bash
git clone https://github.com/MinLeeKR/ImageJ-Macros.git
cd ImageJ-Macros
```

2. Python 환경에서 MkDocs와 Material 테마를 설치합니다.

```bash
pip install mkdocs-material
```

3. 로컬 개발 서버를 실행합니다.

```bash
mkdocs serve
```

4. 브라우저에서 `http://127.0.0.1:8000/` 로 접속해 변경사항을 확인합니다.

## 2. GitHub Actions 를 통한 배포

`.github/workflows/publish.yml` 의 내용은 다음과 같습니다.

```yaml
name: build-website
on:
  push:
    branches:
      - main
      - master

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: 3.x
      - run: pip install mkdocs-material
      - run: mkdocs gh-deploy --force
```

이 설정 덕분에 `main` 브랜치에 변경사항을 push 하면  
GitHub Actions 가 자동으로 MkDocs 빌드 및 `gh-pages` 브랜치 배포를 수행합니다.

## 3. GitHub Pages 설정 확인

1. GitHub 저장소의 **Settings → Pages** 메뉴로 이동합니다.
2. Source 가 `Deploy from a branch` 이고, 브랜치가 `gh-pages` 로 설정되어 있는지 확인합니다.
3. 상단에 표시되는 URL (예: `https://minleekr.github.io/ImageJ-Macros/`) 을 클릭하면 배포된 사이트를 볼 수 있습니다.

