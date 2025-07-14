 <!-- coco030 작업영역 -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Object loginMember = session.getAttribute("loginMember");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch</title>
    <style>
        .header-right-wrapper 
        {	display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px; }
    </style>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head>
<body>
<div class="header-right-wrapper">
<% if (loginMember == null) { %>    
    <a href="${pageContext.request.contextPath}/join">회원가입</a>
    <br>
    <a href="${pageContext.request.contextPath}/login">로그인</a>
<% } else { 
       com.springmvc.domain.Member member = (com.springmvc.domain.Member) loginMember;
%>
    <a href="${pageContext.request.contextPath}/mypage">나의 영화 기록</a>
    <a href="${pageContext.request.contextPath}/editForm">회원 정보 수정</a>
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
<% } %>
</div>
</body>
</html>
