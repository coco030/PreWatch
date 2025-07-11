<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%System.out.println("회원정보 수정 뷰-비밀번호 변경만 있음- 진입"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보 수정 페이지</title>
</head>
<body>
  <form action="${pageContext.request.contextPath}/updatePassword" method="post">
    <input type="hidden" name="id" value="${loginMember.id}" />
    <label>새 비밀번호:</label>
    <input type="password" name="newPassword" required /><br />
    <label>새 비밀번호 확인:</label>
    <input type="password" name="confirmPassword" required /><br />
    <button type="submit">비밀번호 수정</button>
  </form>
  <c:if test="${not empty errorMessage}">
    <p style="color:red">${errorMessage}</p>
  </c:if>
</body>
</html>