/**
 * Copyright (c) 2002-2014 "Neo Technology,"
 * Network Engine for Objects in Lund AB [http://neotechnology.com]
 *
 * This file is part of Neo4j.
 *
 * Neo4j is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.neo4j.cypher.internal.compiler.v2_1.ast.rewriters

import org.neo4j.cypher.internal.commons.CypherFunSuite
import org.neo4j.cypher.internal.compiler.v2_1._
import org.neo4j.cypher.internal.compiler.v2_1.ast.Statement

trait RewriteTest {
  self: CypherFunSuite =>

  import parser.ParserFixture._

  def rewriterUnderTest: Rewriter
  val semantickChecker = new SemanticChecker(mock[SemanticCheckMonitor])

  protected def assertRewrite(originalQuery: String, expectedQuery: String) {
    val original = parseForRewriting(originalQuery)
    val expected = parseForRewriting(expectedQuery)
    semantickChecker.check(originalQuery, original)

    val result = rewrite(original)
    assert(result === expected, "\n" + originalQuery)
  }

  protected def parseForRewriting(queryText: String) = parser.parse(queryText)

  protected def rewrite(original: Statement): AnyRef =
    original.rewrite(bottomUp(rewriterUnderTest))

  protected def assertIsNotRewritten(query: String) {
    val original = parser.parse(query)
    val result = original.rewrite(bottomUp(rewriterUnderTest))
    assert(result === original, "\n" + query)
  }
}
