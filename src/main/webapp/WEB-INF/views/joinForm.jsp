<%--
    파일명: joinForm.jsp
    설명:
        이 JSP 파일은 새로운 회원이 웹사이트에 가입하기 위한 정보를 입력하는 폼 페이지입니다.
        사용자 ID와 비밀번호를 입력받아 회원가입을 처리합니다.
        ID 중복 시 에러 메시지를 표시합니다.

    목적:
        - 사용자가 웹사이트의 회원으로 등록할 수 있도록 가입 폼을 제공합니다.
        - ID 중복 확인과 같은 기본 유효성 검사를 사용자에게 시각적으로 피드백합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%System.out.println("joinForm/회원가입 폼 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 폼</title>
</head>
<body>
    <h2>회원가입</h2>

    <c:if test="${not empty errorMessage}">
        <p style="color:red">${errorMessage}</p>
    </c:if>

    <form action="${pageContext.request.contextPath}/member/join" method="post">
        <p>아이디: <input type="text" name="id" required /></p>
        <p>비밀번호: <input type="password" name="password" required /></p>
        <input type="submit" value="가입하기" />
    </form>
</body>