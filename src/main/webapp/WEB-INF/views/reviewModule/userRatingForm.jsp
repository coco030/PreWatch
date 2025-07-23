<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<input type="hidden" id="movieId" value="${movie.id}" />

<div id="star-container">
    <c:forEach begin="1" end="10" var="i">
        <span class="star" data-value="${i}">${i}</span>
    </c:forEach>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".star").forEach(function (star) {
        star.addEventListener("click", function () {
            const rating = parseInt(this.dataset.value);
            const movieId = document.getElementById("movieId").value;

            console.log("보낼 값 → movieId:", movieId, "rating:", rating);

            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("userRating", rating);

            fetch('${pageContext.request.contextPath}/review/saveRating', {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                console.log("응답 성공:", data);
                alert("별점 저장 완료!");
            })
            .catch(err => {
                console.error("요청 실패:", err);
                alert("요청 실패: " + err.message);
            });
        });
    });
});
</script>
