<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("홈 뷰 진입"); %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% Object loginMember = session.getAttribute("loginMember"); %>
<html>
	<head>
		<title>Welcome</title>
</head>
	<body>	
<c:if test="${empty sessionScope.loginMember}">
	    <%-- 로그인 안 한 경우 --%>
	    <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
	    <a href="${pageContext.request.contextPath}/login">로그인</a>
	</c:if>
	 	<%-- 로그인 한 경우 --%>
	<c:if test="${not empty sessionScope.loginMember}">
	    <p>${sessionScope.loginMember.id}님, 환영합니다.</p><br>
	    <a href="${pageContext.request.contextPath}/member/mypage">나의 기록</a><br>
	    <a href="${pageContext.request.contextPath}/member/editForm">비밀번호 수정</a>
	    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
	</c:if>		
	<br>
	 <hr>
	    <h2>영화 목록 (나중에 추가될 영역)</h2>
	    <%-- 이 곳에 영화 뷰 모듈이 들어옵니다. --%>
	</body>
</html>