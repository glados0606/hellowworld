import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "SnapSOAP — AI 임상노트 구조화 에디터",
  description: "자유텍스트 진료 기록을 SOAP 포맷으로 자동 구조화",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body className="min-h-screen bg-gray-50">
        {/* 헤더 */}
        <header className="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-14">
              {/* 로고 */}
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-violet-600 rounded-lg flex items-center justify-center shadow-sm">
                  <span className="text-white font-bold text-sm">S</span>
                </div>
                <div>
                  <h1 className="text-base font-bold text-gray-900 leading-tight">
                    SnapSOAP
                  </h1>
                  <p className="text-xs text-gray-400 -mt-0.5 leading-none">
                    AI Clinical Note Structurizer
                  </p>
                </div>
              </div>

              {/* 우측 정보 */}
              <div className="flex items-center gap-3 text-xs text-gray-400">
                <span className="hidden sm:block">
                  자유텍스트 → SOAP 자동 구조화
                </span>
                <span className="px-2 py-1 bg-violet-50 text-violet-600 rounded-md font-medium border border-violet-100">
                  Prototype v0.1
                </span>
              </div>
            </div>
          </div>
        </header>

        {/* 메인 콘텐츠 */}
        <main>{children}</main>

        {/* 푸터 */}
        <footer className="border-t border-gray-200 bg-white mt-auto">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
            <p className="text-xs text-center text-gray-400">
              SnapSOAP는 프로토타입입니다. 실제 환자 정보를 입력하지 마세요.
              AI 분류 결과는 반드시 의료진이 검토해야 합니다.
            </p>
          </div>
        </footer>
      </body>
    </html>
  );
}
