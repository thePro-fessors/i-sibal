# i-Sibal 프로젝트 구축 완료 요약 (Walkthrough)

모든 요구사항과 제약사항을 만족하는 `i-Sibal` 프로젝트의 초기 디렉토리 구조와 자동화 스크립트 작성을 완료했습니다. 이번 마일스톤에서는 "wlan1 동글 이슈 해결"과 "TUI 통합 관리 환경"이 새롭게 추가되었습니다.

## 새롭게 추가/강화된 기능

1. **동적 무선 인터페이스 감지 (`02_setup_ap.sh`)**
   * 기존에 `wlan0`으로 하드코딩되었던 AP 구축 스크립트를 개선했습니다.
   * `iw dev` 명령어로 물리적 인터페이스를 감지하며, 내장 Wi-Fi(wlan0)와 USB 동글(wlan1)이 동시에 켜져 있거나 이름이 변경되더라도 **Whiptail TUI 라디오 버튼 메뉴에서 눈으로 보고 핫스팟용 인터페이스를 선택**할 수 있게 방어 로직을 구현했습니다.

2. **통합 TUI 메인 관리자 (`i-sibal.sh`)**
   * 루트 디렉토리에 직관적인 인터페이스를 제공하는 `i-sibal.sh`를 추가했습니다.
   * `sudo ./i-sibal.sh` 한 줄로 다음 기능들을 관리할 수 있습니다:
     * 모드 스위칭 (안정성 / 저지연)
     * AP 이름 및 비밀번호 재설정
     * USB 동글 인식 여부(IP 주소) 및 상태 확인
     * `journalctl -f`를 매핑한 실시간 미러링 에러 로그 확인

## 구현된 핵심 산출물 (전체 리뷰)

* [README.md](file:///Users/satellite/개발/RPiAirPlay/README.md): 프로젝트 전체 사용 가이드 및 하드웨어 구성 안내, TUI 실행법.
* [01_install_deps.sh](file:///Users/satellite/개발/RPiAirPlay/scripts/01_install_deps.sh): TUI용 `whiptail` 및 `iw` 패키지 자동 설치 추가.
* [02_setup_ap.sh](file:///Users/satellite/개발/RPiAirPlay/scripts/02_setup_ap.sh): TUI 환경에서 사용자로부터 입력값을 받아 AP를 구성하도록 전면 재작성됨.
* [03_install_uxplay.sh](file:///Users/satellite/개발/RPiAirPlay/scripts/03_install_uxplay.sh): GStreamer와 H.264 하드웨어 디코더 컴파일.
* [04_config_system.sh](file:///Users/satellite/개발/RPiAirPlay/scripts/04_config_system.sh): 색감 문제 방지를 위한 `hdmi_pixel_encoding=2` (Full RGB) 강제 지정.
* [i-sibal-stable.service](file:///Users/satellite/개발/RPiAirPlay/config/i-sibal-stable.service) & [lowlat.service](file:///Users/satellite/개발/RPiAirPlay/config/i-sibal-lowlat.service): 프레임 드랍을 원천 차단하는 기본 안정성 데몬과 립싱크 중심의 저지연 데몬 분리.
* [i-sibal.sh](file:///Users/satellite/개발/RPiAirPlay/i-sibal.sh): CLI 타이핑의 번거로움을 해결하는 위 모든 과정의 중앙 통제 스크립트.

## 다음 검증 목표
실제 라즈베리파이 터미널 창에서 **`sudo ./i-sibal.sh`**를 실행해 보시고 파란색 메뉴 화면이 예쁘게 잘 뜨는지, `네트워크 인터페이스 확인` 메뉴를 눌렀을 때 wlan1이 정상적으로 조회되는지 확인해 주세요!
