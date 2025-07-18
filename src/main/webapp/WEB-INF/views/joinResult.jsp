<%--
    파일명: joinResult.jsp
    설명:
        이 JSP 파일은 회원가입이 성공적으로 완료된 후 사용자에게 보여지는 확인 페이지입니다.
        사용자에게 가입이 완료되었음을 알리고, 홈페이지나 로그인 페이지로 이동할 수 있는 링크를 제공합니다.

    목적:
        - 회원가입 프로세스의 성공을 사용자에게 명확히 확인시켜줍니다.
        - 가입 후 사용자가 다음 단계(로그인 또는 메인 페이지 탐색)로 쉽게 이동할 수 있도록 안내합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("회원가입 결과 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>가입 완료 후 확인 페이지</title>
</head>
<body>
<p>가입을 축하드립니다.</p>
	<a href="${pageContext.request.contextPath}">홈으로 가기</a>

	<a href="${pageContext.request.contextPath}/auth/login">로그인하기</a>
</body>