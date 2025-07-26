<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- JSP 상단 스크립틀릿과 태그 라이브러리 선언은 그대로 둡니다. --%>
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
   
	<!-- Bootstrap Icons  -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
   <style> 

        .main-footer {
            background-color: #212529; /* 진한 회색 (검은색 계열) */
            color: #adb5bd; /* 밝은 회색 텍스트 */
            text-align: center;
            padding: 40px 20px;
            font-size: 14px;
        }

        .main-footer a {
            color: #dee2e6; /* 기본 링크 색상 */
            text-decoration: none;
            transition: color 0.2s;
        }

        .main-footer a:hover {
            color: #ffffff; /* 마우스 올렸을 때 더 밝게 */
            text-decoration: underline;
        }

        .main-footer .footer-links {
            margin-bottom: 1rem;
        }

        .main-footer .copyright {
            font-size: 0.8rem;
            color: #6c757d; 
        }
        /* --- // 끝: 푸터 스타일 --- */


        /* --- 모바일 메뉴 및 반응형 설정 --- */
        .mobile-bottom-nav { display: none; }

        @media (max-width: 768px) {
            .main-footer { display: none; }
            body { padding-bottom: 56px; } /* 모바일 메뉴에 가려지지 않게 */
            
            .stats-display-box { padding: 2.5rem 1rem; }
            .stats-display-box p { font-size: 1rem; }

            .mobile-bottom-nav {
                display: flex; justify-content: space-around; align-items: center;
                position: fixed; bottom: 0; left: 0; width: 100%; height: 56px;
                background-color: #fff; border-top: 1px solid #ddd;
                box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1); z-index: 1050;
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
            <a href="#">프로젝트 기간 : 25.07.08~25.07.2?</a> |
            <a href="https://github.com/qowlsgh4544/">깃허브 @qowlsgh4544</a> |
            <a href="https://github.com/coco030">깃허브 @coco030</a>
        </div>
        <div class="mt-2">
            <p class="mb-0">© 2025 PreWatch. All Rights Reserved.</p>
        </div>
    </footer>

    <!-- 모바일 하단 메뉴 -->
    <%-- 1. 로그인하지 않은 사용자 --%>
    <% if (loginMember == null) { %>
        <div class="mobile-bottom-nav">
            <a href="${pageContext.request.contextPath}/"><i class="bi bi-house-door"></i>홈</a>
            <a href="${pageContext.request.contextPath}/auth/login"><i class="bi bi-box-arrow-in-right"></i>로그인</a>
            <a href="${pageContext.request.contextPath}/member/join"><i class="bi bi-person-plus"></i>회원가입</a>
        </div>
    <%-- 2. 일반 회원(MEMBER)으로 로그인한 사용자 --%>
    <% } else if ("MEMBER".equals(userRole)) { %>
        <div class="mobile-bottom-nav">
            <a href="${pageContext.request.contextPath}/"><i class="bi bi-house-door"></i>홈</a>
            <a href="${pageContext.request.contextPath}/member/wishlist" class="wishlist-link"><i class="bi bi-heart"></i>보고싶어요</a>
            <a href="${pageContext.request.contextPath}/member/mypage"><i class="bi bi-journal-text"></i>나의 기록</a>
            <a href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right"></i>로그아웃</a>
        </div>
    <%-- 3. 관리자(ADMIN)로 로그인한 사용자 --%>
    <% } else if ("ADMIN".equals(userRole)) { %>
        <div class="mobile-bottom-nav">
            <a href="${pageContext.request.contextPath}/"><i class="bi bi-house-door"></i>홈</a>
            <a href="${pageContext.request.contextPath}/movies"><i class="bi bi-box"></i>관리자 대시보드</a>
            <a href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right"></i>로그아웃</a>
        </div>
    <% } %>
</body>
</html>