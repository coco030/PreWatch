<%--
    파일명: editForm.jsp
    설명:
        이 JSP 파일은 로그인한 회원이 자신의 비밀번호를 수정하거나 회원 탈퇴를 요청하는 페이지입니다.
        현재 비밀번호를 다시 입력하는 과정 없이 새 비밀번호를 바로 설정하도록 되어 있습니다. (보안상 약점일 수 있으나 현재 구현은 이렇습니다.)

    목적:
        - 사용자가 자신의 계정 정보를 직접 관리(비밀번호 변경, 회원 탈퇴)할 수 있도록 UI를 제공합니다.
        - 회원 탈퇴 시 계정 상태를 'INACTIVE'로 변경하여 데이터는 유지하되 서비스 이용을 중단시킵니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%System.out.println("회원정보 수정 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보 수정 페이지</title>
</head>
<body>

  <form action="${pageContext.request.contextPath}/member/updatePassword" method="post">
    <input type="hidden" name="id" value="${sessionScope.loginMember.id}" />
    <label>새 비밀번호:</label>
    <input type="password" name="pw" required /><br />
    <label>새 비밀번호 확인:</label>
    <input type="password" name="confirmPassword" required /><br />
    <button type="submit">비밀번호 수정</button>
</form>
	<br>
	<form action="${pageContext.request.contextPath}/member/deactivateUser" method="post">
    <button type="submit">회원 탈퇴</button>
</form>
  <c:if test="${not empty errorMessage}">
    <p style="color:red">${errorMessage}</p>
  </c:if>
</body>