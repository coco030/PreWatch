<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<div class="container mt-4">
  <h2 class="section-title mb-4">🎬 개봉 예정작</h2>

  <c:choose>
    <c:when test="${not empty upcomingMovies}">
      <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-4">
        <c:forEach var="movie" items="${upcomingMovies}">
          <div class="col">
            <div class="card h-100 shadow-sm border-0">

              <%-- 포스터 경로 처리 --%>
              <c:set var="posterSrc">
                <c:choose>
                  <c:when test="${not empty movie.poster_path and movie.poster_path ne 'N/A'}">
                    <c:choose>
                      <c:when test="${fn:startsWith(movie.poster_path, 'http://') or fn:startsWith(movie.poster_path, 'https://')}">
                        ${movie.poster_path}
                      </c:when>
                      <c:otherwise>
                        ${pageContext.request.contextPath}${movie.poster_path}
                      </c:otherwise>
                    </c:choose>
                  </c:when>
                  <c:otherwise>
                    ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                  </c:otherwise>
                </c:choose>
              </c:set>

              <%-- 포스터 출력 --%>
              <img src="${posterSrc}" class="card-img-top w-100" style="height: 250px; object-fit: cover;" alt="${movie.title} 포스터" />

              <%-- 텍스트 출력 --%>
              <div class="card-body text-center px-2">
                <h6 class="card-title text-truncate mb-2" title="${movie.title}">${movie.title}</h6>

                <c:choose>
                  <c:when test="${movie.dday > 0}">
                    <p class="text-primary mb-0">D-${movie.dday}</p>
                  </c:when>
                  <c:when test="${movie.dday == 0}">
                    <p class="text-danger mb-0">D-DAY</p>
                  </c:when>
                  <c:otherwise>
                    <p class="text-muted mb-0">D+${-movie.dday}</p>
                  </c:otherwise>
                </c:choose>
              </div>

            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <p class="text-muted">개봉 예정 영화가 없습니다.</p>
    </c:otherwise>
  </c:choose>
</div>
