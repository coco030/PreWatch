<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>PreWatch 메인</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
</head>
<body class="bg">
  <div class="container py-4">

    <!-- 최근 등록된 영화 -->
    <h2 class="section-title">최근 등록된 영화</h2>
    <div class="row g-4 justify-content-center">
      <c:forEach var="movie" items="${movies}" begin="0" end="2">
        <div class="col-6 col-md-4 col-lg-4">
          <div class="movie-card">
            <div class="rank-badge">NEW</div>
            <a href="<c:url value='/movies/${movie.id}'/>">
              <c:set var="posterSrc">
                <c:choose>
                  <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                    <c:choose>
                      <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                        ${movie.posterPath}
                      </c:when>
                      <c:otherwise>
                        ${pageContext.request.contextPath}${movie.posterPath}
                      </c:otherwise>
                    </c:choose>
                  </c:when>
                  <c:otherwise>
                    ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                  </c:otherwise>
                </c:choose>
              </c:set>
              <img src="${posterSrc}" alt="${movie.title} 포스터" />
              <div class="p-3">
                <h5 class="fw-bold">${movie.title}</h5>
                <p class="text-muted mb-1">${movie.year} | ${movie.genre}</p>
                <p class="text-muted mb-0">평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
              </div>
            </a>
          </div>
        </div>
      </c:forEach>
    </div>

    <!-- 배너 버튼 -->
    <div class="banner-section">
      <div class="d-flex flex-wrap justify-content-center">
        <a href="<c:url value='/recommend'/>" class="banner-button">추천</a>
        <a href="<c:url value='/calendar'/>" class="banner-button">캘린더</a>
        <a href="<c:url value='/event'/>" class="banner-button">이벤트</a>
        <c:choose>
          <c:when test="${not empty loginMember}">
            <a href="<c:url value='/review/myreviewSummary'/>" class="banner-button">나의 취향 분석</a>
          </c:when>
          <c:otherwise>
            <!-- id="iframeLoginModal"인 모달. -->
            <span class="banner-button" 
                  data-bs-toggle="modal" 
                  data-bs-target="#iframeLoginModal" 
                  style="cursor: pointer;">
              나의 취향 분석
            </span>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- 개봉 예정작 -->
    <jsp:include page="/WEB-INF/views/movie/upcomingMovies.jsp" />

    <!-- 추천 랭킹 -->
    <h2 class="section-title">PreWatch 추천 랭킹</h2>
    <div class="row g-3 justify-content-center">
      <c:set var="rank" value="0" />
      <c:forEach var="movie" items="${recommendedMovies}">
        <c:set var="rank" value="${rank + 1}" />
        <div class="col-6 col-sm-4 col-md-3 col-lg-2">
          <div class="movie-card">
            <div class="rank-badge">${rank}</div>
            <a href="<c:url value='/movies/${movie.id}'/>">
              <c:set var="posterSrc">
                <c:choose>
                  <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                    <c:choose>
                      <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                        ${movie.posterPath}
                      </c:when>
                      <c:otherwise>
                        ${pageContext.request.contextPath}${movie.posterPath}
                      </c:otherwise>
                    </c:choose>
                  </c:when>
                  <c:otherwise>
                    ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                  </c:otherwise>
                </c:choose>
              </c:set>
              <img src="${posterSrc}" alt="${movie.title} 포스터" />
              <div class="p-2">
                <h5 class="fw-semibold small">${movie.title}</h5>
                <p class="text-muted small mb-1">${movie.year} | ${movie.genre}</p>
                <p class="text-muted small mb-1">찜 : ${movie.likeCount}</p>
              </div>
            </a>
          </div>
        </div>
      </c:forEach>
    </div>

    <!-- 관리자 추천 영화 -->
    <h2 class="section-title">PreWatch 추천 영화</h2>
    <c:choose>
      <c:when test="${not empty adminRecommendedMovies}">
        <div class="row g-3 justify-content-center">
          <c:set var="rank" value="0" />
          <c:forEach var="movie" items="${adminRecommendedMovies}">
            <c:set var="rank" value="${rank + 1}" />
            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
              <div class="movie-card">
                <div class="rank-badge">${rank}</div>
                <a href="<c:url value='/movies/${movie.id}'/>">
                  <c:set var="posterSrc">
                    <c:choose>
                      <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                        <c:choose>
                          <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                            ${movie.posterPath}
                          </c:when>
                          <c:otherwise>
                            ${pageContext.request.contextPath}${movie.posterPath}
                          </c:otherwise>
                        </c:choose>
                      </c:when>
                      <c:otherwise>
                        ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                      </c:otherwise>
                    </c:choose>
                  </c:set>
                  <img src="${posterSrc}" alt="${movie.title} 포스터" />
                  <div class="p-2">
                    <h5 class="fw-semibold small">${movie.title}</h5>
                    <p class="text-muted small mb-1">${movie.year} | ${movie.genre}</p>
                    <p class="text-muted small mb-1">찜 : ${movie.likeCount}</p>
                  </div>
                </a>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="no-movie-box">
          아직 추천 영화가 없습니다.
        </div>
      </c:otherwise>
    </c:choose>

  </div> 


  <!--  ==========로그인 모달===========   -->
  <div class="modal fade" id="iframeLoginModal" tabindex="-1" aria-labelledby="iframeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="iframeModalLabel">로그인을 하셔야 이용하실 수 있어요</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body p-0" style="height: 400px;">
          <iframe src="<c:url value='/auth/login'/>" 
                  style="width: 100%; height: 100%; border: none;"
                  title="로그인 프레임">
          </iframe>
        </div>
      </div>
    </div>
  </div>
  <!-- ==========로그인 모달 끝=========== -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>