<%--
    파일명: wishlist.jsp
    설명:
        이 JSP 파일은 로그인한 사용자가 찜한 영화 목록을 표시하는 페이지입니다.
        `MemberController`의 `showWishlistPage` 메서드로부터 `likedMovies` 리스트를 받아와,
        `main.jsp`와 유사한 그리드 형태로 영화 정보를 표시합니다.

    목적:
        - 사용자가 찜한 영화들을 한눈에 볼 수 있도록 개인화된 찜 목록을 제공합니다.
        - 찜한 영화의 포스터, 제목, 평점 등을 표시합니다. (찜 개수는 표시하지 않습니다.)

    연결 관계:
        - `MemberController.java`: `showWishlistPage` (GET /member/wishlist) 메서드에서 `likedMovies` 리스트를 모델에 담아 이 JSP로 전달합니다.
        - `movie.java` 도메인 객체: `likedMovies` 리스트의 각 요소인 `movie` 객체의 필드를 사용하여 정보를 표시합니다.
        - `layout/header.jsp`, `layout/footer.jsp`: 웹사이트의 공통 헤더와 푸터를 포함합니다.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%System.out.println("wishlist 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<title>나의 찜 영화 목록</title>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
/* 메인 콘텐츠와 추천 랭킹을 감싸는 wrapper */
.main-content-wrapper {
    display: flex;
    flex-direction: column;
    gap: 0;
    align-items: center;
    max-width: 1200px;
    margin: 20px auto;
    padding: 0;
    background-color: transparent;
    box-shadow: none;
    border-radius: 0;
}

/* wishlist (기존과 동일) */
.wishlist.container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    padding: 20px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    box-sizing: border-box;
    margin-bottom: 20px;
}

/* wishlist 컨테이너 영화 카드 레이아웃 (기존과 동일) */
.wishlist .movie-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(350px, 1fr));
    gap: 20px;
    max-width: 1090px;
    width: 100%;
    margin: 0 auto;
    justify-content: center;
}

/* 개별 섹션 컨테이너 스타일 (main.container와 second_container에 공통 적용) */
.main.container, .second_container, .third_container { /* ⭐ third_container 추가 (7-24 오후12:41 추가 된 코드) */
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    padding: 20px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    box-sizing: border-box;
}

/* 마진 조정: main.container 하단 마진 제거 */
.main.container {
    margin-bottom: 0;
}

/* 마진 조정: second_container 상단 마진 제거 */
.second_container {
    margin-top: 0;
}

/* ⭐ third_container 상단 마진 조정 (7-24 오후12:41 추가 된 코드) */
.third_container {
    margin-top: 0; /* (7-24 오후12:41 추가 된 코드) */
}


/* 섹션 제목 스타일 - 아래줄 포함 */
.section-title {
    font-size: 20px;
    margin-bottom: 15px;
    border-bottom: 2px solid #eee;
    padding-bottom: 10px;
    width: 100%;
    text-align: left;
    box-sizing: border-box;
}

/* 메인 컨테이너 영화 카드 레이아웃: 반응형 그리드 */
.main .movie-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(350px, 1fr));
    gap: 20px;
    max-width: 1090px;
    width: 100%;
    margin: 0 auto;
    justify-content: center;
}

/* 추천 랭킹 컨테이너 영화 카드 레이아웃: 반응형 그리드 */
.second_container .movie-grid, .third_container .movie-grid { /* ⭐ third_container 추가 (7-24 오후12:41 추가 된 코드) */
    display: grid;
    grid-template-columns: repeat(5, minmax(180px, 1fr));
    gap: 20px;
    max-width: 980px;
    width: 100%;
    margin: 0 auto;
    justify-content: center;
}

/* 개별 영화 카드 스타일 */
.movie-card {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    text-align: center;
    padding-bottom: 15px;
    position: relative; /* 자식 요소의 절대 위치 지정을 위해 추가 */
}

/* **순위 배지 스타일** */
.movie-card .rank-badge {
    position: absolute;
    top: 10px; /* 상단에서 10px 떨어진 위치 */
    left: 10px; /* 좌측에서 10px 떨어진 위치 */
    background-color: rgba(100, 100, 100, 0.8); /* 어두운 회색 배경 (반투명) */
    color: white; /* 흰색 글자 */
    font-size: 1.1em; /* 글자 크기 */
    font-weight: bold; /* 글자 굵게 */
    padding: 5px 8px; /* 내부 여백 */
    border-radius: 5px; /* 모서리 둥글게 */
    z-index: 10; /* 포스터 위에 표시되도록 z-index 설정 */
    min-width: 25px; /* 한 자리 숫자, 두 자리 숫자 모두 보기 좋게 최소 너비 설정 */
    text-align: center; /* 숫자 중앙 정렬 */
}


/* 메인 컨테이너 영화 포스터 이미지 크기 고정 + 비율 유지 */
.main .movie-card img {
    width: 100%;
    height: auto;
    aspect-ratio: 2 / 3;
    object-fit: cover;
}

/* 추천 랭킹 컨테이너 영화 포스터 이미지 크기 고정 + 비율 유지 */
.second_container .movie-card img, .third_container .movie-card img { /* ⭐ third_container 추가 (7-24 오후12:41 추가 된 코드) */
    width: 100%;
    height: 270px;
    object-fit: cover;
}

/* 영화 제목 스타일 */
.movie-card h3 {
    font-size: 16px;
    margin: 10px 0 5px;
    padding: 0 10px;
}

/* 영화 정보 텍스트 (장르, 연도 등) */
.movie-card p {
    font-size: 14px;
    color: #666;
    margin: 0;
    padding: 0 10px;
}

/* 카드 전체 링크 스타일 초기화 */
.movie-card a {
    text-decoration: none;
    color: inherit;
}

/* 링크에 마우스 올렸을 때 제목만 색 강조 */
.movie-card a:hover h3 {
    color: #007bff;
}


.favorite-button-wrapper {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    margin-top: 20px;
}
.favorite-button {
    background-color: #f44336;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    margin-bottom: 10px;
}
.favorite-button:hover {
    background-color: #d32f2f;
}
.favorite-button.disabled,
.favorite-button.processing {
    background-color: #cccccc;
    cursor: not-allowed;
}
.like-count-detail {
    font-size: 1.2em;
    color: #555;
    font-weight: bold;
}

/* 배너 섹션 스타일 */
.banner-section {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 15px 60px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 80px;
    box-sizing: border-box;
}

/* **배너 섹션 스타일 업데이트** */
.banner-section {
    width: 100%;
    /* max-width는 main-content-wrapper와 동일하게 유지 */
    max-width: 1200px;
    /* 상하 마진을 0으로 설정하여 위아래 요소에 딱 붙게 함 */
    margin: 0 auto;
    /* 좌우 패딩을 더 넓게 설정하여 거의 끝까지 닿도록 함 */
    padding: 15px 60px; /* 기존 40px에서 60px로 늘림 */
    background-color: white; /* 배경색 흰색 유지 */
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 80px;
    box-sizing: border-box;
}

/* 배너 내부 콘텐츠 및 버튼 스타일은 이전과 동일 */
.banner-content {
    display: flex;
    gap: 20px;
}

.banner-button {
    background-color: #E2E2E2;
    color: white;
    padding: 12px 25px;
    border: none;
    border-radius: 25px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s ease, transform 0.2s ease;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    margin-left:50px;
    margin-right:50px;
}

.banner-button:hover {
    background-color: #0056b3;
    transform: translateY(-2px);
}

.banner-button:active {
    background-color: #004085;
    transform: translateY(0); }

</style>
</head>
<body>
    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <main class="second_container">
        <h2 class="section-title">나의 찜 영화 목록</h2>

        <c:choose>
            <c:when test="${not empty likedMovies}">
                <div class="movie-grid">
                    <c:forEach var="movie" items="${likedMovies}">
                        <div class="movie-card">
                            <%-- 찜 아이콘 컨테이너 --%>
                            <div class="heart-info-container">
                                <i class="heart-icon
                                    <c:choose>
                                        <c:when test="${movie.isLiked()}">fas fa-heart</c:when>
                                        <c:otherwise>far fa-heart</c:otherwise>
                                    </c:choose>
                                    <c:if test="${empty sessionScope.loginMember || sessionScope.userRole == 'ADMIN'}">disabled</c:if>
                                "
                                   data-movie-id="${movie.id}"
                                   onclick="toggleCart(this)"></i>
                                <%-- 찜 개수 span 제거 ⭐ --%>
                            </div>
                            <a href="<c:url value='/movies/${movie.id}'/>">
                                <c:set var="posterSrc">
                                    <c:choose>
                                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                            <c:if test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                ${movie.posterPath}
                                            </c:if>
                                            <c:if test="${not (fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://'))}">
                                                ${pageContext.request.contextPath}${movie.posterPath}
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            ${pageContext.request.contextPath}/resources/images/default_poster.jpg
                                        </c:otherwise>
                                    </c:choose>
                                </c:set>
                                <img src="${posterSrc}" alt="${movie.title} 포스터" />
                                <h3>${movie.title}</h3>
                                <p>${movie.year} | ${movie.genre}</p>
                                <p>평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
                                <p>폭력성 지수: <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></p>
                            </a>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <p class="no-movies-message">찜한 영화가 없습니다. <a href="<c:url value='/'/>">홈으로 돌아가</a> 새로운 영화를 탐색해보세요!</p>
            </c:otherwise>
        </c:choose>
    </main>

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>