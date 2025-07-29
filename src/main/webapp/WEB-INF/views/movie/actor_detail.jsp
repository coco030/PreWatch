<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<h2>${actor.name}</h2>

<img src="https://image.tmdb.org/t/p/w300/${actor.profile_image_url}" width="150" />

<!-- 생년월일 / 사망 여부 -->
<p>
  <strong>출생일:</strong> ${actor.birthday}
  <c:if test="${not empty actor.deathday}">
    ~ ${actor.deathday} (${actor.age}세 사망)
  </c:if>
  <c:if test="${empty actor.deathday}">
    (${actor.age}세)
  </c:if>
</p>

<!-- 출생지 -->
<c:if test="${not empty actor.place_of_birth}">
  <p><strong>출생지:</strong> ${actor.place_of_birth}</p>
</c:if>

<!-- 성별 -->
<c:if test="${not empty actor.gender}">
  <p><strong>성별:</strong> 
    <c:choose>
      <c:when test="${actor.gender == 1}">여성</c:when>
      <c:when test="${actor.gender == 2}">남성</c:when>
      <c:otherwise>기타/미지정</c:otherwise>
    </c:choose>
  </p>
</c:if>

<!-- 활동 분야 -->
<c:if test="${not empty actor.known_for_department}">
  <p><strong>활동 분야:</strong> ${actor.known_for_department}</p>
</c:if>

 <p><strong>영화</strong> 
<c:set var="currentYear" value="" scope="page" />

<c:forEach var="movie" items="${movieList}">
    <c:set var="releaseYear" value="${empty movie.release_date ? '미정' : fn:substring(movie.release_date, 0, 4)}" />

    <!-- 연도 그룹 시작/종료 -->
    <c:if test="${currentYear ne releaseYear}">
        <c:if test="${not empty currentYear}">
            </div> <!-- 이전 movie-row 닫기 -->
        </c:if>
        <h3 style="margin-top:30px;">${releaseYear}년</h3>
        <div class="movie-row" style="display:flex; flex-wrap:wrap; gap:24px 16px;">
        <c:set var="currentYear" value="${releaseYear}" scope="page" />
    </c:if>

    <!-- 영화 카드: a태그로 감싸기 -->
    <a href="${pageContext.request.contextPath}/movies/${movie.id}" style="text-decoration:none; color:inherit;">
      <div class="movie-card" style="width:180px; border:1px solid #eee; border-radius:10px; padding:12px; box-shadow:0 2px 8px #eee;">
          <c:choose>
              <c:when test="${not empty movie.poster_path and fn:startsWith(movie.poster_path, 'http')}">
                  <img src="${movie.poster_path}" width="100%" style="border-radius:8px;"/>
              </c:when>
              <c:when test="${not empty movie.poster_path}">
                  <img src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" width="100%" style="border-radius:8px;"/>
              </c:when>
              <c:otherwise>
                  <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="100%" style="border-radius:8px;"/>
              </c:otherwise>
          </c:choose>
          <div style="font-weight:bold; margin-top:8px; font-size:15px;">${movie.title}</div>
          <div style="color:#888; font-size:13px;">
              <c:if test="${not empty movie.release_date}">${movie.release_date}</c:if>
              <c:if test="${not empty movie.role_name}"><br/>${movie.role_name}</c:if>
          </div>
      </div>
    </a>
</c:forEach>
<!-- 마지막 연도 그룹 닫기 -->
</div>


