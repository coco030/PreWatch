<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        /* 부트스트랩 푸터 스타일 */
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

        /* 모바일 화면 전용 스타일 */
        @media (max-width: 768px) {
            .main-footer {
                display: none;
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

            .mobile-bottom-nav a {
                flex: 1;
                text-align: center;
                font-size: 14px;
                color: #333;
                padding: 10px 0;
                text-decoration: none;
                font-weight: 500;
            }

            /* hover 시 텍스트와 아이콘 동시에 색상 진하게 */
				.mobile-bottom-nav a:hover,
				.mobile-bottom-nav a:hover i {
				    color: #000;
				    font-weight: 600;
				}

	        /* 하단 메뉴 아이콘 스타일*/
	        .mobile-bottom-nav a i {
	            display: block;
	            font-size: 18px;
	            margin-bottom: 2px;
	        }
	        
	        /* 기본 상태: 빈 하트 */
			.wishlist-link i {
			    transition: color 0.2s ease, transform 0.2s ease;
			    color: #888; /* 연회색 */
			}
			
			/* hover 시: 채운 하트 + 빨간색 강조 */
			.wishlist-link:hover i::before {
			    content: "\f415"; /* bi-heart-fill */
			    font-family: "Bootstrap-icons";
			    color: crimson;
			}
			.wishlist-link:hover {
			    color: crimson;
			    font-weight: 600;
			}
			.wishlist-link:hover i {
			    transform: scale(1.1);
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

<!-- 모바일 하단 메뉴: 로그인 상태별로 다른 메뉴 -->
<!-- 로그인한 일반 회원 -->
<% if (loginMember != null && "MEMBER".equals(userRole)) { %>
    <div class="mobile-bottom-nav">
        <a href="${pageContext.request.contextPath}/">
            <i class="bi bi-house-door"></i>홈
        </a>
        <a href="${pageContext.request.contextPath}/member/wishlist"
		   class="wishlist-link"
		   onmouseenter="fillHeart(this)" onmouseleave="emptyHeart(this)">
		   <i class="bi bi-heart"></i>보고싶어요
		</a>
        <a href="${pageContext.request.contextPath}/member/mypage">
            <i class="bi bi-journal-text"></i>기록
        </a>
        <a href="${pageContext.request.contextPath}/auth/logout">
            <i class="bi bi-box-arrow-right"></i>로그아웃
        </a>
    </div>

<!-- 비로그인 상태 -->
<% } else if (loginMember == null) { %>
    <div class="mobile-bottom-nav">
        <a href="${pageContext.request.contextPath}/">
            <i class="bi bi-house-door"></i>홈
        </a>
        <a href="${pageContext.request.contextPath}/auth/login">
            <i class="bi bi-box-arrow-in-right"></i>로그인
        </a>
        <a href="${pageContext.request.contextPath}/member/join">
            <i class="bi bi-person-plus"></i>회원가입
        </a>
    </div>
<% } %>

    <!-- Bootstrap JS + Bootstrap Icons (아이콘 쓰는 경우) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.js"></script>
	<script>
	function fillHeart(el) {
	    const icon = el.querySelector('i');
	    icon.classList.remove('bi-heart');
	    icon.classList.add('bi-heart-fill');
	    icon.style.color = 'crimson';
	}
	
	function emptyHeart(el) {
	    const icon = el.querySelector('i');
	    icon.classList.remove('bi-heart-fill');
	    icon.classList.add('bi-heart');
	    icon.style.color = '#888';
	}
	</script>
</body>
</html>
