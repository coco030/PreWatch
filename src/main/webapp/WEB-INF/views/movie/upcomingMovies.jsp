<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<div class="container mt-0">
  <h4 class="mb-3"><strong>🎬 개봉 예정작</strong></h4>

  <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-5 g-4">
    <c:forEach var="movie" items="${upcomingMovies}">
      <div class="col">
        <div class="card h-100 shadow-sm">
          <img src="${movie.poster_path}" class="card-img-top" style="height: 250px; object-fit: cover;" alt="${movie.title}">
          <div class="card-body text-center">
            <h6 class="card-title mb-2">${movie.title}</h6>

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
</div>
