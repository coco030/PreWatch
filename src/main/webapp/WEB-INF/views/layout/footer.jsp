<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> <%-- 숫자 포맷팅을 위해 추가 --%>
<%
    Object loginMemberObj = session.getAttribute("loginMember");
    String userRole = (String) session.getAttribute("userRole");
    com.springmvc.domain.Member loginMember = null;
    if (loginMemberObj != null) {
        loginMember = (com.springmvc.domain.Member) loginMemberObj;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>PreWatch</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
   
	<!-- Bootstrap Icons (CSS 방식) -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        /* 기존 PC 푸터 스타일 */
        .main-footer {
            background-color: #f8f9fa;
            text-align: center;
            padding: 20px;
            font-size: 14px;
            color: #6c757d;
        }

        /* 모바일 하단 고정 메뉴 (기본은 숨김) */
        .mobile-bottom-nav {
            display: none;
        }

        /* --- 신규 추가: 통계 표시바 스타일 --- */
        .stats-ticker {
            position: fixed;
            bottom: 20px; /* PC 화면에서의 기본 위치 */
            left: 50%;
            transform: translateX(-50%);
            background-color: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            z-index: 1040; /* 모바일 메뉴보다는 아래에 위치 */
            font-size: 14px;
            display: flex;
            gap: 20px; /* 항목 사이 간격 */
            align-items: center;
            opacity: 0; /* 초기에는 숨김 */
            animation: fadeIn 1s forwards; /* 서서히 나타나는 애니메이션 */
            animation-delay: 0.5s; /* 페이지 로드 후 0.5초 뒤에 나타남 */
        }
        
        @keyframes fadeIn {
            to { opacity: 1; }
        }

        .stats-ticker .stat-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .stats-ticker .stat-item i {
            font-size: 1.2em;
            color: #ffc107; /* 아이콘 색상 */
        }

        .stats-ticker .stat-item span {
            font-weight: bold;
            min-width: 40px; /* 숫자가 변경될 때 너비가 변하지 않도록 */
            text-align: right;
        }

        /* 모바일 화면 전용 스타일 */
        @media (max-width: 768px) {
            .main-footer {
                display: none; /* PC용 푸터는 모바일에서 숨김 */
            }

            .mobile-bottom-nav {
                display: flex;
                justify-content: space-around;
                align-items: center;
                position: fixed;
                bottom: 0;
                left: 0;
                width: 100%;
                height: 56px;
                background-color: #fff;
                border-top: 1px solid #ddd;
                box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
                z-index: 1050;
            }

            /* 모바일에서는 통계 바가 하단 메뉴 바로 위에 위치하도록 조정 */
            .stats-ticker {
                bottom: 66px; /* 56px(메뉴 높이) + 10px(여백) */
                width: 90%;
                font-size: 12px;
                padding: 8px 15px;
                flex-direction: column; /* 모바일에서는 세로로 표시 */
                gap: 5px;
            }

            .mobile-bottom-nav a { flex: 1; text-align: center; font-size: 14px; color: #333; padding: 10px 0; text-decoration: none; font-weight: 500; }
            .mobile-bottom-nav a:hover, .mobile-bottom-nav a:hover i { color: #000; font-weight: 600; }
	        .mobile-bottom-nav a i { display: block; font-size: 18px; margin-bottom: 2px; }
			.wishlist-link i { transition: color 0.2s ease, transform 0.2s ease; color: #888; }
			.wishlist-link:hover i::before { content: "\f415"; font-family: "Bootstrap-icons"; color: crimson; }
			.wishlist-link:hover { color: crimson; font-weight: 600; }
			.wishlist-link:hover i { transform: scale(1.1); }
        }
    </style>
</head>
<body>

    <!-- 푸터 (PC 전용) -->
    <footer class="footer main-footer">
        <div>
            <a href="#">프로젝트 기간 : 25.07.08~25.07.25</a> |
            <a href="https://github.com/qowlsgh4544/">깃허브 @qowlsgh4544</a> |
            <a href="https://github.com/coco030">깃허브 @coco030</a>
        </div>
        <div class="mt-2">
            <p class="mb-0">© 2025 PreWatch. All Rights Reserved.</p>
        </div>
    </footer>

    <!-- ⭐ 새로운 실시간 통계 표시 영역 ⭐ -->
    <div class="stats-ticker">
        <div class="stat-item">
            <i class="bi bi-chat-dots-fill"></i>
            <span>리뷰 <strong id="reviewCount" data-count="${globalStats.totalReviewContentCount}">0</strong>개</span>
        </div>
        <div class="stat-item">
            <i class="bi bi-star-fill"></i>
            <span>별점 <strong id="ratingCount" data-count="${globalStats.totalUserRatingCount}">0</strong>개</span>
        </div>
        <div class="stat-item">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>폭력성 평가 <strong id="violenceCount" data-count="${globalStats.totalViolenceScoreCount}">0</strong>개</span>
        </div>
    </div>


    <!-- 모바일 하단 메뉴: 로그인 상태별로 다른 메뉴 -->
    <!-- 로그인한 일반 회원 -->
    <% if (loginMember != null && "MEMBER".equals(userRole)) { %>
        <div class="mobile-bottom-nav">
            <a href="${pageContext.request.contextPath}/"><i class="bi bi-house-door"></i>홈</a>
            <a href="${pageContext.request.contextPath}/member/wishlist" class="wishlist-link"><i class="bi bi-heart"></i>보고싶어요</a>
            <a href="${pageContext.request.contextPath}/member/mypage"><i class="bi bi-journal-text"></i>나의 기록</a>
            <a href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right"></i>로그아웃</a>
        </div>
    <!-- 비로그인 상태 -->
    <% } else if (loginMember == null) { %>
        <div class="mobile-bottom-nav">
            <a href="${pageContext.request.contextPath}/"><i class="bi bi-house-door"></i>홈</a>
            <a href="${pageContext.request.contextPath}/auth/login"><i class="bi bi-box-arrow-in-right"></i>로그인</a>
            <a href="${pageContext.request.contextPath}/member/join"><i class="bi bi-person-plus"></i>회원가입</a>
        </div>
    <% } %>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    // 페이지 로드가 완료되면 실행
    document.addEventListener('DOMContentLoaded', function() {
        
        // 숫자 카운트업 애니메이션 함수
        function animateCountUp(element, duration) {
            const finalCount = parseInt(element.dataset.count, 10);
            if (isNaN(finalCount)) return;

            let startTimestamp = null;
            const step = (timestamp) => {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = Math.min((timestamp - startTimestamp) / duration, 1);
                const currentCount = Math.floor(progress * finalCount);
                // 1000 단위 콤마 추가
                element.innerText = currentCount.toLocaleString();
                if (progress < 1) {
                    window.requestAnimationFrame(step);
                } else {
                    element.innerText = finalCount.toLocaleString();
                }
            };
            window.requestAnimationFrame(step);
        }

        // 각 통계 항목에 애니메이션 적용
        const reviewCountEl = document.getElementById('reviewCount');
        const ratingCountEl = document.getElementById('ratingCount');
        const violenceCountEl = document.getElementById('violenceCount');
        
        if (reviewCountEl) animateCountUp(reviewCountEl, 2000); // 2초 동안 애니메이션
        if (ratingCountEl) animateCountUp(ratingCountEl, 2000);
        if (violenceCountEl) animateCountUp(violenceCountEl, 2000);
    });

    
	</script>
</body>
</html>