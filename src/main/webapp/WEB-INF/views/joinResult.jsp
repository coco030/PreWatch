<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
 <%System.out.println("회원가입 결과 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>가입 완료 후 확인 페이지</title>
</head>
<body>
<p>가입을 축하드립니다.</p>
<!--"${pageContext.request.contextPath}" 대신에  "/PreWatch" 이렇게 해도 되지만 혹시 바뀔지도 모르니깐 -->
	<a href="${pageContext.request.contextPath}">홈으로 가기</a>
	<a href="login">로그인하기</a>
</body>
</html>