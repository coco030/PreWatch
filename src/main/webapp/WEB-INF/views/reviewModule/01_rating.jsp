<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String movieId = request.getParameter("movieId");
if (movieId == null || movieId.trim().isEmpty()) return;

Object loginMember = session.getAttribute("loginMember");
%>

<% if (loginMember == null) { %>
    <p>로그인한 사용자만 평점을 남길 수 있습니다.</p>
<% } else { %>
<div data-movie-id="<%= movieId %>">
    <form id="ratingForm">
        <p>평점 (1 ~ 10):</p>
        <select name="rating" id="ratingSelect">
            <% for (int i = 1; i <= 10; i++) { 
                double score = i / 2.0;
            %>
                <option value="<%= i %>"><%= score %></option>
            <% } %>
        </select>
        <button type="submit">저장</button>
    </form>
    <div id="ratingMsg"></div>
</div>

<script>
document.getElementById("ratingForm").addEventListener("submit", function(e) {
    e.preventDefault();
    const score = document.getElementById("ratingSelect").value;
    const movieId = this.parentElement.dataset.movieId;

    fetch("/review/save", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            movieId: Number(movieId),
            userRating: Number(score)
        })
    }).then(res => {
        const msg = document.getElementById("ratingMsg");
        if (res.ok) {
            msg.innerText = "저장 완료";
        } else {
            msg.innerText = "저장 실패";
        }
    });
});
</script>
<% } %>