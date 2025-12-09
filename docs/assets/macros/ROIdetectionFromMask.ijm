// ==========================================
// Robust Label Map to ROI Manager
// ==========================================

macro "Label Map to ROIs v2" {
    // 1. 초기화 (Overlay 제거, 선택 해제, ROI 매니저 초기화)
    run("Select None");
    run("Remove Overlay"); // 기존에 화면에 붙어있는 숫자나 라벨 제거
    
    if (isOpen("ROI Manager")) {
        selectWindow("ROI Manager");
        run("Close");
    }
    
    // 이미지가 열려있는지 확인
    if (nImages == 0) {
        showMessage("Error", "이미지를 먼저 열어주세요.");
        return;
    }

    // 2. 이미지 분석 준비
    id = getImageID();
    title = getTitle();
    bit_depth = bitDepth();
    
    // 히스토그램 범위 설정 (8-bit: 256, 16-bit: 65536)
    nBins = 256;
    if (bit_depth == 16) nBins = 65536;
    
    // 히스토그램을 얻어 존재하는 픽셀 값만 파악
    getHistogram(values, counts, nBins);
    
    // ROI 매니저 실행
    run("ROI Manager...");
    
    // 속도 향상을 위한 Batch Mode (화면 갱신 중지)
    setBatchMode(true);
    
    print("\\Clear");
    print("ROI 추출 시작...");

    // 3. Loop: 존재하는 픽셀 값(Cell Index)에 대해서만 ROI 생성
    // i=0은 배경(0)이므로 건너뜀
    found_count = 0;
    
    for (i = 1; i < nBins; i++) {
        // 해당 인덱스(밝기값)를 가진 픽셀이 하나라도 있으면 실행
        if (counts[i] > 0) {
            
            // Log에 진행상황 표시 (너무 자주 찍으면 느려지므로 10개 단위로)
            if (found_count % 10 == 0) {
                showStatus("Processing Index: " + i);
            }

            // 정확히 i 값만 선택 (Threshold)
            setThreshold(i, i);
            
            // 선택 영역 생성 (Create Selection)
            run("Create Selection");
            
            // 선택이 정상적으로 되었다면 ROI Manager에 추가
            if (selectionType() != -1) {
                roiManager("Add");
                
                // 마지막에 추가된 ROI 선택 후 이름 변경
                count = roiManager("count");
                roiManager("Select", count - 1);
                roiManager("Rename", "Cell_" + i);
                
                found_count++;
            }
        }
    }

    // 4. 마무리
    run("Select None");
    resetThreshold();
    setBatchMode(false); // 화면 갱신 재개
    
    // 결과 확인 설정
    if (found_count > 0) {
        roiManager("Show All with labels");
        print("완료: 총 " + found_count + "개의 ROI가 생성되었습니다.");
    } else {
        showMessage("Warning", "ROI를 찾지 못했습니다.\n이미지의 픽셀 값이 0(배경)만 있는지 확인해보세요.");
    }
}