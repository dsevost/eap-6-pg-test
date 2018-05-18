<html>

<body>
	<h1>Cluster information</h1>
	<h2>
		<p>
			Local server name (cluster node): <%= System.getProperty("jboss.node.name") + "/" + System.getProperty("jboss.server.name" + "/" + java.net.InetAddress.getHostAddress()  %>
			<br/> Server name: <%= request.getServerName() %>
			<br/>
		</p>
	</h2>
	<h1>Datasource test</h1>
	<%
    	String jndiName;
    	String sqlString;
    	java.sql.Connection connection = null;
    	java.sql.Statement statement = null;

    	jndiName = request.getParameter("jndiName");
    	if (jndiName == null) {
			jndiName = System.getenv("DB_JNDI");
			if(jndiName == null) {
				jndiName = "";
			}
    	}
    	sqlString = request.getParameter("sqlString");
    	if (sqlString == null) {
			sqlString = 
				"-- create table if not exists keypair (k integer not null primary key, v varchar(256)); \n" +
				"-- insert into keypair VALUES (1, 'value 1'); \n" +
				"-- insert into keypair VALUES (2, 'value 2'); \n" +
				"-- select k,v from keypair; \n" +
			"";
    	}
	%>
		<form>
			<table>
				<thead>
					<tr>
						<th></th>
						<th></th>
					</tr>
				</thead>
				<tr>
					<td>
						<label>JNDI name</label>
					</td>
					<td>
						<input name="jndiName" type="input" value="<%= jndiName %>" size="42" />
					</td>
				</tr>
				<tr>
					<td>
						<label>SQL String</label>
					</td>
					<td>
						<textarea name="sqlString" rows="10" cols="120"><%= sqlString %></textarea>
					</td>
				</tr>
				<tr align="center">
					<td colspan="2">
						<input name="submit" type="submit" />
					</td>
				</tr>
				<tbody>
				</tbody>
			</table>
		</form>
		<%
    if (!jndiName.equals("") && !sqlString.equals("")) {
	try {
	    javax.naming.InitialContext context;
	    context = new javax.naming.InitialContext();
	    javax.sql.DataSource ds = (javax.sql.DataSource) context.lookup(jndiName);
	    connection = ds.getConnection();
	    statement = connection.createStatement();
	    if (sqlString.toUpperCase().startsWith("SELECT")) {
		java.sql.ResultSet rs = statement.executeQuery(sqlString);
		java.sql.ResultSetMetaData rsmd = rs.getMetaData();

		int columns = rsmd.getColumnCount();

		out.println("<table border=\"1\">");
		out.println("<tr>");
		for (int i = 1; i <=columns; i ++ ) {
		    out.println("<th>" + rsmd.getColumnName(i) + "</th>");
		}
		out.println("</tr>");
		while(rs.next()) {
		    out.println("<tr>");
		    for(int i = 1; i <= columns; i ++ ) {
			out.println("<td>" + rs.getObject(i) + "</td>");
		    }
		    out.println("</tr>");
		}
		out.println("</table>");
		rs.close();
	    } else {
		statement.executeUpdate(sqlString);
	    }
	} finally {
	    try {
		statement.close();
	    } catch (Exception e) {
		e.printStackTrace(new java.io.PrintWriter(out));
	    } finally {
		statement = null;
	    }
	    try {
		connection.close();
	    } catch (Exception e) {
		e.printStackTrace(new java.io.PrintWriter(out));
	    } finally {
		connection = null;
	    }
	}
    }
%>

</body>

</html>