<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- 공통 로그인 상태 전달 --%>
<c:if test="${not empty sessionScope.loginMember}">
  <c:set var="loginMember" value="${sessionScope.loginMember}" scope="request" />
</c:if>

<div class="header-wrapper">
    <jsp:include page="/WEB-INF/views/layout/header-left.jsp" />
    <jsp:include page="/WEB-INF/views/layout/header-center.jsp" />
    <jsp:include page="/WEB-INF/views/layout/header-right.jsp" />
</div>
