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

<!-- 소개 -->
<c:if test="${not empty actor.biography}">
  <h4>소개</h4>
  <p style="white-space: pre-line;">${actor.biography}</p>
</c:if>

<!-- 참여 영화 목록 -->
<h2>참여한 영화</h2>
<c:if test="${not empty movieList}">
  <ul>
    <c:forEach var="movie" items="${movieList}">
      <li>
        <strong>${movie.title}</strong><br/>
<c:choose>
  <c:when test="${not empty movie.poster_path and fn:startsWith(movie.poster_path, 'http')}">
    <img src="${movie.poster_path}" width="80" />
  </c:when>
  <c:when test="${not empty movie.poster_path}">
    <img src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" width="80" />
  </c:when>
  <c:otherwise>
    <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
  </c:otherwise>
</c:choose>


        <span style="color:gray;">
          <c:if test="${not empty movie.role_name}"> (${movie.role_name})</c:if>
        </span>
      </li>
    </c:forEach>
  </ul>
</c:if>
