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
package org.neo4j.cypher.internal.compiler.v2_1.planner.logical

import org.neo4j.graphdb.Direction
import org.neo4j.cypher.internal.commons.CypherFunSuite
import org.neo4j.cypher.internal.compiler.v2_1.planner.LogicalPlanningTestSupport
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans._
import org.neo4j.cypher.internal.compiler.v2_1.ast._
import org.mockito.Mockito._
import org.mockito.Matchers._
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.OuterHashJoin
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.IdName
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.AllNodesScan
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.Expand
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.SingleRow
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.Projection
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.NodeByLabelScan
import org.neo4j.cypher.internal.compiler.v2_1.planner.logical.plans.Optional

class OptionalMatchPlanningIntegrationTest extends CypherFunSuite with LogicalPlanningTestSupport   {

  test("should build plans containing joins") {
    implicit val planContext = newMockedPlanContext
    val factory = newMockedMetricsFactory
    when(factory.newCardinalityEstimator(any(), any(), any())).thenReturn((plan: LogicalPlan) => plan match {
      case _: AllNodesScan => 2000000
      case _: NodeByLabelScan => 20
      case _: Expand => 10
      case _: OuterHashJoin => 20
      case _: SingleRow => 1
      case _ => Double.MaxValue
    })
    implicit val planner = newPlanner(factory)
    when(planContext.getOptLabelId("X")).thenReturn(None)
    when(planContext.getOptLabelId("Y")).thenReturn(None)

    produceLogicalPlan("MATCH (a:X)-[r1]->(b) OPTIONAL MATCH (b)-[r2]->(c:Y) RETURN b") should equal(
      Projection(
        OuterHashJoin("b",
          Expand(NodeByLabelScan("a", Left("X")), "a", Direction.OUTGOING, Seq(), "b", "r1", SimplePatternLength),
          Expand(NodeByLabelScan("c", Left("Y")), "c", Direction.INCOMING, Seq(), "b", "r2", SimplePatternLength)
        ),
        expressions = Map("b" -> ident("b"))
      )
    )
  }

  test("should build simple optional match plans") {
    implicit val planContext = newMockedPlanContext
    implicit val planner = newPlanner(newMockedMetricsFactory)
    produceLogicalPlan("OPTIONAL MATCH a RETURN a") should equal(
      Optional(AllNodesScan("a"))
    )
  }

  // FIXME: Davide, Jakub 2014/5/8 - this is broken in ronja
  ignore("should build simple optional match plans with expand") {
    implicit val planContext = newMockedPlanContext
    implicit val planner = newPlanner(newMockedMetricsFactory)
    produceLogicalPlan("OPTIONAL MATCH a WITH a MATCH a-[r]->(b) RETURN a, r, b") should equal(
      Expand(Optional(AllNodesScan("a")), "a", Direction.OUTGOING, Seq.empty, "b", "r", SimplePatternLength)
    )
  }

  test("should solve multiple optional matches") {
    // OPTIONAL MATCH (a)-[r]->(b)
    implicit val planContext = newMockedPlanContext(hardcodedStatistics)
    implicit val planner = newPlanner(newMockedMetricsFactory)

    when(planContext.getOptRelTypeId("R1")).thenReturn(None)
    when(planContext.getOptRelTypeId("R2")).thenReturn(None)

    produceLogicalPlan("MATCH a OPTIONAL MATCH (a)-[:R1]->(x1) OPTIONAL MATCH (a)-[:R2]->(x2) RETURN a, x1, x2") should equal(
      Projection(
        OptionalExpand(
          OptionalExpand(
            AllNodesScan(IdName("a")),
            IdName("a"), Direction.OUTGOING, List(RelTypeName("R1")_), IdName("x1"), IdName("  UNNAMED26"), SimplePatternLength, Seq.empty),
          IdName("a"), Direction.OUTGOING, List(RelTypeName("R2")_), IdName("x2"), IdName("  UNNAMED57"), SimplePatternLength, Seq.empty),
        Map("a" -> ident("a"), "x1" -> ident("x1"), "x2" -> ident("x2")
        )
      )
    )
  }
}
