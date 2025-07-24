<%-- layout/main.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container main-content-wrapper">
    <div class="main container">
        <h2 class="section-title">최근 등록된 영화</h2>
        <div class="movie-grid">
            <c:choose>
                <c:when test="${not empty movies}"> <%-- 'movies'는 최근 등록된 영화를 위해 사용됩니다 --%>
                    <%-- movies 리스트에서 상위 3개만 표시하도록 제한 (Controller에서 3개만 가져올 것을 가정) --%>
                    <c:forEach var="movie" items="${movies}">
                        <div class="movie-card">
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
                                            <c:set var="posterSrc" value="${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png" />
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
                </c:when>
                <c:otherwise>
                    <p>아직 등록된 영화가 없습니다. <a href="<c:url value='/movies/new'/>">새 영화를 등록</a>하거나 <a href="<c:url value='/movies'/>">영화 목록</a>에서 API를 통해 가져와보세요!</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <hr/> <%-- 구분선 추가 --%>

    <div class="banner-section">
        <div class="banner-content">
            <button class="banner-button" onclick="location.href='#'">추천</button>
            <button class="banner-button" onclick="location.href='#'">캘린더</button>
            <button class="banner-button" onclick="location.href='#'">이벤트</button>
            <button class="banner-button" onclick="location.href='#'">취향 분석</button>
        </div>
    </div>
    <hr/> <%-- 구분선 추가 --%>

    <div class="second_container">
        <h2 class="section-title">PreWatch 추천 랭킹</h2> <%-- 이 섹션은 이제 like_count 기반의 기존 추천 랭킹을 보여줍니다. (7-24 오후12:41 추가 된 코드) --%>
        <div class="movie-grid">
            <c:choose>
                <c:when test="${not empty recommendedMovies}"> <%-- 'recommendedMovies'는 기존 찜 개수 기반 추천 영화를 위해 사용됩니다 (7-24 오후12:41 추가 된 코드) --%>
                    <%-- recommendedMovies 리스트에서 상위 5개만 표시 (Controller에서 5개만 가져올 것을 가정) --%>
                    <c:set var="rank" value="0" /> <%-- 순위 변수 초기화 --%>
                    <c:forEach var="movie" items="${recommendedMovies}">
                        <c:set var="rank" value="${rank + 1}" /> <%-- 순위 1씩 증가 --%>
                        <div class="movie-card">
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
                                <div class="rank-badge">${rank}</div> <%-- 순위 배지 추가 --%>
                                <h3>${movie.title}</h3>
                                <p>${movie.year} | ${movie.genre}</p>
                                <p>평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
                                <p>폭력성 지수: <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></p>
                                <%-- 찜 개수 표시 (매우 중요!) --%>
                                <p>찜 개수: ${movie.likeCount}</p>
                            </a>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p>아직 추천할 영화가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
        
   <hr/> <%-- coco030이 추가한 내역 --%>
	<div class="upcoming-movie-section">
	  <%--  <h2 class="section-title">개봉 예정작</h2> --%>
	    <jsp:include page="/WEB-INF/views/movie/upcomingMovies.jsp" />
	</div>
	<hr/> <%-- coco030이 추가한 내역 끝 + 다음 섹션 구분선 --%>
    
    

    <hr/> <%-- 구분선 추가 (7-24 오후12:41 추가 된 코드) --%>

    <div class="third_container"> <%-- 새로운 섹션 컨테이너 (7-24 오후12:41 추가 된 코드) --%>
        <h2 class="section-title">PreWatch 추천 영화</h2> <%-- 새로운 섹션 제목 (7-24 오후12:41 추가 된 코드) --%>
        <div class="movie-grid"> <%-- (7-24 오후12:41 추가 된 코드) --%>
            <c:choose> <%-- (7-24 오후12:41 추가 된 코드) --%>
                <c:when test="${not empty adminRecommendedMovies}"> <%-- 새로운 모델 속성 사용 (7-24 오후12:41 추가 된 코드) --%>
                    <c:set var="rank" value="0" /> <%-- (7-24 오후12:41 추가 된 코드) --%>
                    <c:forEach var="movie" items="${adminRecommendedMovies}"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                        <c:set var="rank" value="${rank + 1}" /> <%-- (7-24 오후12:41 추가 된 코드) --%>
                        <div class="movie-card"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                            <a href="<c:url value='/movies/${movie.id}'/>"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <c:set var="posterSrc"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                    <c:choose> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                            <c:if test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                                ${movie.posterPath} <%-- (7-24 오후12:41 추가 된 코드) --%>
                                            </c:if> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                            <c:if test="${not (fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://'))}"> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                                ${pageContext.request.contextPath}${movie.posterPath} <%-- (7-24 오후12:41 추가 된 코드) --%>
                                            </c:if> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                        </c:when> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                        <c:otherwise> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                            ${pageContext.request.contextPath}/resources/images/default_poster.jpg <%-- (7-24 오후12:41 추가 된 코드) --%>
                                        </c:otherwise> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                    </c:choose> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                </c:set> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <img src="${posterSrc}" alt="${movie.title} 포스터" /> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <div class="rank-badge">${rank}</div> <%-- 순위 배지 추가 (7-24 오후12:41 추가 된 코드) --%>
                                <h3>${movie.title}</h3> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <p>${movie.year} | ${movie.genre}</p> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <p>평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <p>폭력성 지수: <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></p> <%-- (7-24 오후12:41 추가 된 코드) --%>
                                <p>찜 개수: ${movie.likeCount}</p> <%-- (7-24 오후12:41 추가 된 코드) --%>
                            </a> <%-- (7-24 오후12:41 추가 된 코드) --%>
                        </div> <%-- (7-24 오후12:41 추가 된 코드) --%>
                    </c:forEach> <%-- (7-24 오후12:41 추가 된 코드) --%>
                </c:when> <%-- (7-24 오후12:41 추가 된 코드) --%>
                <c:otherwise> <%-- (7-24 오후12:41 추가 된 코드) --%>
                    <p>아직 추천 영화가 없습니다.<c:if test="${userRole eq 'ADMIN'}"> 관리자는 <a href="<c:url value='/admin/banner-movies'/>">추천 영화를 등록</a>할 수 있습니다.</c:if></p> <%-- (7-24 오후12:41 추가 된 코드) --%>
                </c:otherwise> <%-- (7-24 오후12:41 추가 된 코드) --%>
            </c:choose> <%-- (7-24 오후12:41 추가 된 코드) --%>
        </div> <%-- (7-24 오후12:41 추가 된 코드) --%>
    </div> <%-- (7-24 오후12:41 추가 된 코드) --%>
</div>