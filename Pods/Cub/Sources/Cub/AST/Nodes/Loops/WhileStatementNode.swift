//
//  WhileStatementNode.swift
//  Cub
//
//  Created by Louis D'hauwe on 21/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public struct WhileStatementNode: LoopNode {

	public let condition: ASTNode
	public let body: BodyNode
	public let range: Range<Int>?

	public init(condition: ASTNode, body: BodyNode, range: Range<Int>?) throws {

		self.condition = condition
		self.body = body
		self.range = range
		
		guard condition.isValidConditionNode else {
			throw compileError(.unexpectedCommand)
		}
	}

	func compileLoop(with ctx: BytecodeCompiler, scopeStart: Int) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		ctx.pushLoopContinue(scopeStart)

		let conditionInstruction = try condition.compile(with: ctx, in: self)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()

		let bodyBytecode = try body.compile(with: ctx, in: self)

		let goToEndLabel = ctx.nextIndexLabel()

		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [.index(peekNextLabel)], range: range)

		bytecode.append(ifeq)
		bytecode.append(contentsOf: bodyBytecode)

		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [.index(scopeStart)], range: range)
		bytecode.append(goToStart)

		guard let _ = ctx.popLoopContinue() else {
			throw compileError(.unexpectedCommand)
		}

		return bytecode
	}

	public var childNodes: [ASTNode] {
		return [condition, body]
	}

	public var description: String {

		var str = "WhileStatementNode(condition: \(condition), body: "

		str += "\n    \(body.description)"

		str += ")"

		return str
	}

	public var nodeDescription: String? {
		return "while"
	}

	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)

		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)

		children.append(bodyChildNode)

		return children
	}

}
