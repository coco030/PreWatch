<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("joinForm/회원가입 폼 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 폼</title>
</head>
<body>
    <h2>회원가입</h2>
    
     <!-- 에러 메시지 출력 -->
    <c:if test="${not empty errorMessage}">
        <p style="color:red">${errorMessage}</p>
    </c:if>
    
    <form action="${pageContext.request.contextPath}/join" method="post">
        <p>아이디: <input type="text" name="id" required /></p>
        <p>비밀번호: <input type="password" name="password" required /></p>
        <input type="submit" value="가입하기" />
    </form>
</body>
</html>