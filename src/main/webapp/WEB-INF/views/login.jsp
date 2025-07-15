<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% System.out.println("로그인 페이지 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
</head>
<body>
    <h2>로그인</h2>
    <c:if test="${not empty errorMessage}">
        <p style="color:red;">${errorMessage}</p>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth/login" method="post">
        <p>아이디: <input type="text" name="id" required /></p>
        <p>비밀번호: <input type="password" name="password" required /></p>
        <input type="submit" value="로그인" />
    </form>

    <br>
    <p>아직 회원이 아니신가요? <a href="${pageContext.request.contextPath}/member/join">회원가입</a></p>
</body>