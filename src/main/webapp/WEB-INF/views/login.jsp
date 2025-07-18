<%--
    파일명: login.jsp
    설명:
        이 JSP 파일은 사용자가 로그인하기 위한 폼 페이지입니다.
        아이디와 비밀번호를 입력받아 로그인을 시도하고, 로그인 실패 시 에러 메시지를 표시합니다.
        회원가입 페이지로 이동하는 링크도 제공합니다.

    목적:
        - 사용자가 웹사이트의 서비스에 접근하기 위해 인증(로그인)할 수 있는 UI를 제공합니다.
        - 로그인 실패 시 사용자에게 원인을 피드백합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% System.out.println("로그인 페이지 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
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