<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("영화 배우 상세 페이지 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: people 상세 페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
<div class="container py-5">
  <div class="row">
    <!-- 📌 좌측: 배우 프로필 영역 -->
    <div class="col-12 col-md-4 mb-4 mb-md-0">
      <div class="text-center">
        <!-- 정사각형 프로필 사진 -->
        <img src="https://image.tmdb.org/t/p/w300/${actor.profile_image_url}"
             alt="${actor.name}" width="160" height="200"
             class="rounded border shadow-sm"
             style="object-fit: cover;" />

        <!-- 배우 이름 -->
        <h2 class="fw-bold mt-3" style="font-size: 1.8rem; margin-bottom: 30px;">${actor.name}</h2>
      <!-- 글자는 왼쪽 정렬, 박스는 사진 기준 중앙 -->
    <div class="text-start d-inline-block">
      <p><strong><i class="fa-regular fa-calendar-days me-1"></i>출생일:</strong>
        ${actor.birthday}
        <c:if test="${not empty actor.deathday}">
          ~ ${actor.deathday} (${actor.age}세 사망)
        </c:if>
        <c:if test="${empty actor.deathday}">
          (${actor.age}세)
        </c:if>
      </p>

        <c:if test="${not empty actor.place_of_birth}">
        <p><strong><i class="fa-solid fa-map-pin me-1"></i>출생지:</strong> ${actor.place_of_birth}</p>
      </c:if>

      <c:if test="${not empty actor.gender}">
        <p><strong><i class="fa-solid fa-venus-mars me-1"></i>성별:</strong>
          <c:choose>
            <c:when test="${actor.gender == 1}">여성</c:when>
            <c:when test="${actor.gender == 2}">남성</c:when>
            <c:otherwise>기타/미지정</c:otherwise>
          </c:choose>
        </p>
      </c:if>

      <c:if test="${not empty actor.known_for_department}">
        <p><strong><i class="fa-solid fa-clapperboard me-1"></i>활동 분야:</strong> ${actor.known_for_department}</p>
      </c:if>
    </div>
  </div>
</div>

    <!-- 🎬 우측: 필모그래피 목록 -->
    <div class="col-12 col-md-8">
      <h4 class="fw-bold mb-3 border-bottom pb-2">출연작 필모그래피</h4>

      <%-- 연도 그룹 변수 초기화 --%>
      <c:set var="currentYear" value="" scope="page" />
      <c:set var="openGroup" value="false" scope="page" />

      <%-- 필모그래피 루프 --%>
      <c:forEach var="movie" items="${movieList}">
        <c:set var="releaseYear" value="${empty movie.release_date ? '미정' : fn:substring(movie.release_date, 0, 4)}" />

        <c:if test="${currentYear ne releaseYear}">
          <c:if test="${openGroup}">
            </div>
          </c:if>
          <h5 class="mt-4 mb-3">${releaseYear}년</h5>
          <div class="list-group mb-4 shadow-sm rounded">
          <c:set var="currentYear" value="${releaseYear}" scope="page" />
          <c:set var="openGroup" value="true" scope="page" />
        </c:if>

        <a href="${pageContext.request.contextPath}/movies/${movie.id}" 
           class="list-group-item list-group-item-action d-flex align-items-center gap-4 py-3 px-2 border-0 border-bottom"
           style="border-color: #e9ecef;">
          <!-- 포스터 -->
          <div class="flex-shrink-0">
            <c:choose>
              <c:when test="${not empty movie.poster_path and fn:startsWith(movie.poster_path, 'http')}">
                <img src="${movie.poster_path}" width="70" class="rounded shadow-sm"/>
              </c:when>
              <c:when test="${not empty movie.poster_path}">
                <img src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" width="70" class="rounded shadow-sm"/>
              </c:when>
              <c:otherwise>
                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" width="70" class="rounded shadow-sm"/>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- 텍스트 정보 -->
          <div class="d-flex flex-column flex-grow-1">
            <span class="fw-semibold" style="font-size:1.1rem;">${movie.title}</span>
            <span class="text-muted small">${movie.role_name}</span>
            <c:if test="${not empty movie.rating}">
              <span class="text-muted small">평균 ★ ${movie.rating}</span>
            </c:if>
          </div>
        </a>
      </c:forEach>
      <c:if test="${openGroup}">
        </div>
      </c:if>
    </div>
  </div>
</div>


<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>