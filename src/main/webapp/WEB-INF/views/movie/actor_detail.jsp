<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<h2 class="mb-3">${actor.name}</h2>

<div class="mb-4">
    <img src="https://image.tmdb.org/t/p/w300/${actor.profile_image_url}" width="150" class="rounded" />
</div>

<p>
  <strong>출생일:</strong> ${actor.birthday}
  <c:if test="${not empty actor.deathday}">
    ~ ${actor.deathday} (${actor.age}세 사망)
  </c:if>
  <c:if test="${empty actor.deathday}">
    (${actor.age}세)
  </c:if>
</p>

<c:if test="${not empty actor.place_of_birth}">
  <p><strong>출생지:</strong> ${actor.place_of_birth}</p>
</c:if>

<c:if test="${not empty actor.gender}">
  <p><strong>성별:</strong> 
    <c:choose>
      <c:when test="${actor.gender == 1}">여성</c:when>
      <c:when test="${actor.gender == 2}">남성</c:when>
      <c:otherwise>기타/미지정</c:otherwise>
    </c:choose>
  </p>
</c:if>

<c:if test="${not empty actor.known_for_department}">
  <p><strong>활동 분야:</strong> ${actor.known_for_department}</p>
</c:if>

<p class="fw-bold mt-5 mb-3">출연작 필모그래피</p>

<%-- 연도 그룹 분리 로직 --%>
<c:set var="currentYear" value="" scope="page" />
<c:set var="openGroup" value="false" scope="page" />

<c:forEach var="movie" items="${movieList}">
    <c:set var="releaseYear" value="${empty movie.release_date ? '미정' : fn:substring(movie.release_date, 0, 4)}" />
    <c:if test="${currentYear ne releaseYear}">
        <c:if test="${openGroup}">
            </div>
        </c:if>
        <h4 class="mt-4 mb-3">${releaseYear}년</h4>
        <div class="list-group mb-4">
        <c:set var="currentYear" value="${releaseYear}" scope="page" />
        <c:set var="openGroup" value="true" scope="page" />
    </c:if>
    <a href="${pageContext.request.contextPath}/movies/${movie.id}" 
       class="list-group-item list-group-item-action d-flex align-items-center gap-4 py-3 px-2"
       style="border: none; border-bottom: 1px solid #eee;">
        <!-- 포스터 -->
        <div class="flex-shrink-0">
            <c:choose>
                <c:when test="${not empty movie.poster_path and fn:startsWith(movie.poster_path, 'http')}">
                    <img src="${movie.poster_path}" width="70" class="rounded"/>
                </c:when>
                <c:when test="${not empty movie.poster_path}">
                    <img src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" width="70" class="rounded"/>
                </c:when>
                <c:otherwise>
                    <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" width="70" class="rounded"/>
                </c:otherwise>
            </c:choose>
        </div>
        <!-- 텍스트 정보 -->
        <div class="d-flex flex-column flex-grow-1">
		    <span class="fw-bold" style="font-size:1.15rem;">${movie.title}</span>
		    <span class="text-muted small">
		        <c:if test="${not empty movie.role_name}">
		            ${movie.role_name}
		        </c:if>
		    </span>
		    <c:if test="${not empty movie.rating}">
		        <span class="text-muted small">평균 ★ ${movie.rating}</span>
		    </c:if>
		</div>
    </a>
</c:forEach>
<c:if test="${openGroup}">
    </div>
</c:if>
