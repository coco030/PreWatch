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