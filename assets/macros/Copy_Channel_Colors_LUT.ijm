macro "Copy Channel Colors/LUT from Image1 to Image2... " {
    // 1) 열려있는 이미지 목록
    titles = getList("image.titles");
    nTitles = titles.length;
    if (nTitles < 2) exit("두 개 이상의 이미지가 열려 있어야 합니다.");

    // 2) 대화상자
    Dialog.create("Copy channel color/LUT");
    Dialog.addChoice("Source (from)", titles, titles[0]);
    defTarget = titles[0];
    if (nTitles > 1) defTarget = titles[1];
    Dialog.addChoice("Target (to)", titles, defTarget);
    Dialog.addCheckbox("Copy display ranges (Brightness/Contrast)", true);
    Dialog.addCheckbox("Copy channel visibility (active channels)", true);
    Dialog.addCheckbox("Force Composite mode on both", true);
    Dialog.show();

    src = Dialog.getChoice();
    dst = Dialog.getChoice();
    copyRange = Dialog.getCheckbox();
    copyActive = Dialog.getCheckbox();
    forceComposite = Dialog.getCheckbox();
    if (src==dst) exit("Source와 Target이 같습니다. 다른 이미지를 선택하세요.");

    // 3) 채널 수 파악
    selectWindow(src); Stack.getDimensions(w1, h1, c1, z1, t1);
    selectWindow(dst); Stack.getDimensions(w2, h2, c2, z2, t2);
    n = c1; if (c2 < n) n = c2;
    if (n < 1) exit("채널이 없습니다.");

    // 4) Composite 모드 (표시 설정 복사 안정화)
    if (forceComposite) {
        selectWindow(src); Stack.setDisplayMode("composite");
        selectWindow(dst); Stack.setDisplayMode("composite");
    }

    // 5) 채널별 LUT/디스플레이 범위 복사
    for (i = 1; i <= n; i++) {
        selectWindow(src);
        Stack.setChannel(i);
        getLut(r, g, b);
        if (copyRange) getMinAndMax(lo, hi);

        selectWindow(dst);
        Stack.setChannel(i);
        setLut(r, g, b);
        if (copyRange) setMinAndMax(lo, hi);
    }

    // 6) 채널 가시성(Active Channels) 복사
    if (copyActive) {
        selectWindow(src);
        Stack.getActiveChannels(act);   // <-- 값이 act에 "1011" 같은 문자열로 들어감

        // 타깃 채널 수와 길이 맞추기(필요시 잘라내거나 0으로 패딩)
        len = lengthOf(act);
        if (len != c2) {
            if (len > c2) act = substring(act, 0, c2);
            else {
                while (lengthOf(act) < c2) act = act + "0";
            }
        }

        selectWindow(dst);
        Stack.setActiveChannels(act);
    }

    print("Copied LUTs for " + n + " channel(s) from \"" + src + "\" to \"" + dst + "\".");
    if (c1 != c2) print("참고: 채널 수가 달라 앞의 " + n + "개만 복사했습니다 (src=" + c1 + ", dst=" + c2 + ").");
}