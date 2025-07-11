<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("홈 뷰 진입"); %>
<% Object loginMember = session.getAttribute("loginMember"); %>
<html>
	<head>
		<title>Welcome</title>
</head>
	<body>	
<% if (loginMember == null) { %>    
    <a href="${pageContext.request.contextPath}/join">회원가입</a>
    <a href="${pageContext.request.contextPath}/login">로그인</a>
    <p>환영합니다</p>
<% } else { %>
    <% com.springmvc.domain.Member member = (com.springmvc.domain.Member) loginMember; %>
    <p><%= member.getId() %>님, 환영합니다.</p><br>

    <!-- 25.07.10 추가함 -->
    <a href="${pageContext.request.contextPath}/member/mypage">나의 영화 기록</a>
    <a href="${pageContext.request.contextPath}/member/editForm">비밀번호 수정</a>
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
<% } %>	
	</body>
</html>