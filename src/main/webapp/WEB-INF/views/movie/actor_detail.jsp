<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2>${actor.name}</h2>

<img src="https://image.tmdb.org/t/p/w300/${actor.profile_image_url}" width="150" />

<c:if test="${not empty actor.birthday}">
  <p><strong>출생일:</strong> ${actor.birthday}</p>
</c:if>
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

<c:if test="${not empty actor.biography}">
  <h4>소개</h4>
  <p style="white-space: pre-line;">${actor.biography}</p>
</c:if>
