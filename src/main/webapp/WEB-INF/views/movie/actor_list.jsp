<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
	<h2> 감독</h2>
<ul>
  <c:forEach var="person" items="${dbCastList}">
    <c:if test="${person.role_type eq 'DIRECTOR'}">
      <li>
        <a href="${pageContext.request.contextPath}/directors/${person.id}" style="text-decoration:none; color:inherit;">
          <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" width="80" />
          <strong>${person.name}</strong>
        </a>
        <c:if test="${not empty person.role_name}">
          <div style="color:gray;">(${person.role_name} 역)</div>
        </c:if>
      </li>
    </c:if>
  </c:forEach>
</ul>



		
		<h2>👥 배우</h2>

<ul>
  <c:forEach var="person" items="${dbCastList}">
    <c:if test="${person.role_type eq 'ACTOR' and person.name ne directorName}">
      <li>
        <a href="${pageContext.request.contextPath}/actors/${person.id}" style="text-decoration:none; color:inherit;">
          <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}" width="80" />
          <strong>${person.name}</strong>
        </a>
        <c:if test="${not empty person.role_name}">
          (<span style="color:gray;">${person.role_name} 역</span>)
        </c:if>
      </li>
    </c:if>
  </c:forEach>
</ul>