<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<div class="row g-4 justify-content-center"> 
  <c:choose>
    <c:when test="${not empty upcomingMovies}">
      <c:forEach var="movie" items="${upcomingMovies}">

        <%-- 포스터 경로 처리 --%>
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

        <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
          <div class="movie-card">
            <div class="rank-badge">
              <c:choose>
                <c:when test="${movie.dday > 0}">
                  D-${movie.dday}
                </c:when>
                <c:when test="${movie.dday == 0}">
                  D-DAY
                </c:when>
                <c:otherwise>
                  D+${-movie.dday}
                </c:otherwise>
              </c:choose>
            </div>
            <a href="<c:url value='/movies/${movie.id}'/>">
              <img src="${posterSrc}" alt="${movie.title} 포스터" />
              <div class="p-3">
                <h5 class="fw-semibold small text-truncate" title="${movie.title}">${movie.title}</h5>
                <p class="text-muted small mb-1">${movie.year} | ${movie.genre}</p>
                <p class="text-muted small mb-1">찜 : ${movie.likeCount}</p>
              </div>
            </a>
          </div>
        </div>

      </c:forEach>
    </c:when>
    <c:otherwise>
      <p class="text-muted text-center">개봉 예정 영화가 없습니다.</p>
    </c:otherwise>
  </c:choose>
</div>
		